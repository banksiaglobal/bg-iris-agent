import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import fetch from "node-fetch";
import fs from "fs/promises";
import { z, ZodType } from "zod";
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";

// Configuration with default values
const config = {
  apiBaseUrl: process.env.API_BASE_URL || "http://localhost:52773/interoperability/LanguageModelIn",
  openApiUrl: process.env.OPENAPI_URL || "http://localhost:52773/interoperability/LanguageModelIn/openapi",
  openApiFile: process.env.OPENAPI_FILE,
  embeddedOpenApi: process.env.EMBEDDED_OPENAPI,
  apiKey: process.env.API_KEY,
  logLevel: process.env.LOG_LEVEL || "info" // 'debug', 'info', 'warn', 'error'
};

// Simple logger that writes to stderr to avoid interfering with MCP protocol on stdout
const logger = {
  debug: (...args: any) => config.logLevel === 'debug' && console.error('[DEBUG]', ...args),
  info: (...args: any) => ['debug', 'info'].includes(config.logLevel) && console.error('[INFO]', ...args),
  warn: (...args: any) => ['debug', 'info', 'warn'].includes(config.logLevel) && console.error('[WARN]', ...args),
  error: (...args: any) => console.error('[ERROR]', ...args)
};

async function main() {
  logger.info("Starting Banksia Iris Agent MCP bridge server");
  
  // Create MCP server
  const server = new McpServer(
    { name: "banksia-iris-agent-bridge", version: "1.0.0" },
    { capabilities: { tools: {} } }
  );

  // Get OpenAPI definition
  const openApiJson = await getOpenApiDefinition();
  
  // Register tools based on OpenAPI paths
  registerTools(server, openApiJson);

  // Connect server to stdio transport
  const transport = new StdioServerTransport();
  await server.connect(transport);
  
  logger.info("Server running and connected to transport");
}

async function getOpenApiDefinition() {
  logger.debug("Attempting to get OpenAPI definition");
  
  // Try to fetch from URL if provided
  if (config.openApiUrl) {
    try {
      logger.debug(`Fetching OpenAPI from URL: ${config.openApiUrl}`);
      const response = await fetch(config.openApiUrl);
      if (!response.ok) {
        throw new Error(`Failed to fetch OpenAPI definition: ${response.status} ${response.statusText}`);
      }
      const data = await response.json();
      logger.info("Successfully fetched OpenAPI definition from URL");
      return data;
    } catch (error) {
      logger.warn(`Error fetching OpenAPI from URL: ${error instanceof Error ? error.message : String(error)}`);
    }
  } else {
    logger.debug("No OpenAPI URL provided, skipping URL fetch");
  }
  
  // Try to load from file if provided
  if (config.openApiFile) {
    try {
      logger.debug(`Loading OpenAPI from file: ${config.openApiFile}`);
      const fileContent = await fs.readFile(config.openApiFile, 'utf8');
      const data = JSON.parse(fileContent);
      logger.info("Successfully loaded OpenAPI definition from file");
      return data;
    } catch (error) {
      logger.warn(`Error loading OpenAPI from file: ${error instanceof Error ? error.message : String(error)}`);
    }
  } else {
    logger.debug("No OpenAPI file provided, skipping file load");
  }
  
  // Try to use embedded definition if provided
  if (config.embeddedOpenApi) {
    try {
      logger.debug("Using embedded OpenAPI definition");
      const data = JSON.parse(config.embeddedOpenApi);
      logger.info("Successfully parsed embedded OpenAPI definition");
      return data;
    } catch (error) {
      logger.warn(`Error parsing embedded OpenAPI: ${error instanceof Error ? error.message : String(error)}`);
    }
  } else {
    logger.debug("No embedded OpenAPI provided");
  }
    
  // If we get here, we couldn't get the OpenAPI definition
  throw new Error("Failed to get OpenAPI definition from all sources");
}

/**
 * Converts an OpenAPI schema to a Zod schema
 * @param schema The OpenAPI schema object
 * @returns A Zod schema
 */
function convertOpenApiSchemaToZod(schema:any):ZodType {
  // Handle null or undefined schemas
  if (!schema) {
    return z.object({}).passthrough();
  }

  // Handle schema type
  switch (schema.type) {
    case 'string': {
      let stringSchema = z.string();
      
      // Add description if available
      if (schema.description) {
        stringSchema = stringSchema.describe(schema.description);
      }
      
      // Handle specific string formats
      if (schema.format === 'email') {
        stringSchema = z.string().email();
      } else if (schema.format === 'uri' || schema.format === 'url') {
        stringSchema = z.string().url();
      }
      
      // Handle enum values
      if (Array.isArray(schema.enum)) {
        return z.enum(schema.enum);
      }
      
      // Handle constraints
      if (schema.minLength !== undefined) {
        stringSchema = stringSchema.min(schema.minLength);
      }
      if (schema.maxLength !== undefined) {
        stringSchema = stringSchema.max(schema.maxLength);
      }
      if (schema.pattern) {
        try {
          const regex = new RegExp(schema.pattern);
          stringSchema = stringSchema.regex(regex);
        } catch (error) {
          logger.warn(`Invalid regex pattern: ${schema.pattern}`);
        }
      }
      
      return stringSchema;
    }
    
    case 'number':
    case 'integer': {
      let numberSchema = z.number();
      
      // Add description if available
      if (schema.description) {
        numberSchema = numberSchema.describe(schema.description);
      }
      
      // Handle constraints
      if (schema.minimum !== undefined) {
        numberSchema = numberSchema.min(schema.minimum);
      }
      if (schema.maximum !== undefined) {
        numberSchema = numberSchema.max(schema.maximum);
      }
      if (schema.exclusiveMinimum !== undefined) {
        numberSchema = numberSchema.gt(schema.exclusiveMinimum);
      }
      if (schema.exclusiveMaximum !== undefined) {
        numberSchema = numberSchema.lt(schema.exclusiveMaximum);
      }
      
      return numberSchema;
    }
    
    case 'boolean': {
      let boolSchema = z.boolean();
      
      // Add description if available
      if (schema.description) {
        boolSchema = boolSchema.describe(schema.description);
      }
      
      return boolSchema;
    }
    
    case 'array': {
      // If items is defined, use it to validate array items
      if (schema.items) {
        const itemSchema = convertOpenApiSchemaToZod(schema.items);
        let arraySchema = z.array(itemSchema);
        
        // Add description if available
        if (schema.description) {
          arraySchema = arraySchema.describe(schema.description);
        }
        
        // Handle constraints
        if (schema.minItems !== undefined) {
          arraySchema = arraySchema.min(schema.minItems);
        }
        if (schema.maxItems !== undefined) {
          arraySchema = arraySchema.max(schema.maxItems);
        }
        
        return arraySchema;
      }
      
      // Default to array of any
      return z.array(z.any()).describe(schema.description || '');
    }
    
    case 'object': {
      // If properties is defined, create object schema
      if (schema.properties) {
        const shape:any = {};
        const required = Array.isArray(schema.required) ? schema.required : [];
        
        // Process each property
        Object.entries(schema.properties).forEach(([key, propSchema]) => {
          const propZodSchema = convertOpenApiSchemaToZod(propSchema);
          
          // Make non-required properties optional
          shape[key] = required.includes(key) ? propZodSchema : propZodSchema.optional();
        });
        
        let objectSchema:any = z.object(shape);
        
        // Allow additional properties if specified in schema
        if (schema.additionalProperties === true) {
          objectSchema = objectSchema.passthrough();
        }
        
        // Add description if available
        if (schema.description) {
          objectSchema = objectSchema.describe(schema.description);
        }
        
        return objectSchema;
      }
      
      // For objects without defined properties, allow any properties
      return z.record(z.any()).describe(schema.description || '');
    }
    
    // If no type is specified or type isn't recognized, return any
    default:
      return z.any().describe(schema.description || '');
  }
}

function registerTools(server: McpServer, openApiDefinition:any) {
  logger.debug("Registering tools based on OpenAPI definition");
  
  const { paths } = openApiDefinition;
  let toolCount = 0;
  
  for (const [path, methods] of Object.entries<any>(paths)) {
    // In this OpenAPI, all operations are POST
    const operation = methods.post;
    if (!operation) {
      logger.debug(`Skipping path ${path} as it doesn't have a POST method`);
      continue;
    }
    
    const operationId = operation.operationId;
    const summary = operation.summary || "";
    const description = operation.description || "";
    
    // Get the input schema
    const inputSchema = operation.requestBody?.content?.["application/json"]?.schema || { type: "object", properties: {} };
    
    logger.debug(`Registering tool: ${operationId} for path ${path}`);
    
    // Register the tool using the operationId as the name
    server.tool(
      operationId,
      `${summary} ${description}`.trim(),
      {params:convertOpenApiSchemaToZod(inputSchema)},
      async (params:any,extra) => {
        logger.debug(`Tool ${operationId} called with params:`, params);
        
        try {
          // Prepare headers
          const headers:{[key:string]:string} = {
            "Content-Type": "application/json"
          };
          
          // Add authentication if provided
          if (config.apiKey) {
            headers["X-Api-Key"] = config.apiKey;
          }
          
          // Make the API call
          const apiUrl = `${config.apiBaseUrl}${path}`;
          logger.debug(`Making API call to ${apiUrl}`);
          
          const response = await fetch(apiUrl, {
            method: "POST",
            headers,
            body: JSON.stringify(params.params)
          });
          
          if (!response.ok) {
            throw new Error(`API returned status: ${response.status} ${response.statusText}`);
          }
          
          // Parse the response
          let data;
          try {
            data = await response.json();
            logger.debug(`Received API response for ${operationId}`);
          } catch (parseError) {
            // If response is not JSON, try to get it as text
            const text = await response.text();
            logger.warn(`Failed to parse API response as JSON: ${parseError instanceof Error ? parseError.message : String(parseError)}`);
            logger.debug(`Response text: ${text}`);
            throw new Error(`Failed to parse API response as JSON: ${parseError instanceof Error ? parseError.message : String(parseError)}`);
          }
          
          return {
            content: [
              {
                type: "text",
                text: JSON.stringify(data, null, 2)
              }
            ]
          };
        } catch (error) {
          logger.error(`Error calling API for tool ${operationId}: ${error instanceof Error ? error.message : String(error)}`);
          
          return {
            isError: true,
            content: [
              {
                type: "text",
                text: `Error calling API at ${path}: ${error instanceof Error ? error.message : String(error)}`
              }
            ]
          };
        }
      }
    );
    
    toolCount++;
  }
  
  logger.info(`Registered ${toolCount} tools from OpenAPI definition`);
}

// Run the server
main().catch(error => {
  logger.error("Fatal error:", error instanceof Error ? error.message : String(error));
  process.exit(1);
});