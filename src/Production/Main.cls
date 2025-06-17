Class Production.Main Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="Production.Main" TestingEnabled="true" LogGeneralTraceEvents="true">
  <Description>IRIS Agent Production</Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="LanguageModelIn" Category="" ClassName="Banksia.IrisAgent.RestService" PoolSize="1" Enabled="true" Foreground="false" Comment="Banksia Iris Agent Server" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="Port"></Setting>
    <Setting Target="Host" Name="TargetConfigNames">Users,Metrics,Namespaces,Meds,Weather,Light</Setting>
  </Item>
  <Item Name="Users" Category="" ClassName="Production.Operation.Users" PoolSize="1" Enabled="true" Foreground="false" Comment="API for retrieving, searching and create/delete users in the Banksia Iris Agent system." LogTraceEvents="true" Schedule="">
  </Item>
  <Item Name="Metrics" Category="" ClassName="Production.Operation.Metrics" PoolSize="1" Enabled="true" Foreground="false" Comment="API for retrieving and searching information about metrics such as ligs, errors, services, etc in the Banksia Iris Agent system." LogTraceEvents="true" Schedule="">
  </Item>
  <Item Name="Namespaces" Category="" ClassName="Production.Operation.Namespaces" PoolSize="1" Enabled="true" Foreground="false" Comment="API for retrieving, searching and modifying namespaces in the Banksia Iris Agent system." LogTraceEvents="true" Schedule="">
  </Item>
  <Item Name="Meds" Category="" ClassName="Production.Operation.FindMeds" PoolSize="1" Enabled="true" Foreground="false" Comment="API for retrieving and searching information in the external API through Banksia Iris Agent system." LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="SSLConfig">pm.community.intersystems.com</Setting>
    <Setting Target="Adapter" Name="HTTPServer">api.fda.gov</Setting>
    <Setting Target="Adapter" Name="URL">drug/ndc.json</Setting>
  </Item>
  <Item Name="Weather" Category="" ClassName="Production.Operation.Weather" PoolSize="1" Enabled="true" Foreground="false" Comment="API for retrieving and searching weather information in the external API through Banksia Iris Agent system." LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="SSLConfig">pm.community.intersystems.com</Setting>
  </Item>
  <Item Name="Light" Category="" ClassName="Production.Operation.Light" PoolSize="1" Enabled="true" Foreground="false" Comment="API for controlling user&apos;s light." LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="SSLConfig">pm.community.intersystems.com</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Adapter" Name="ExtraHeaders">Content-Type:application/json</Setting>
    <Setting Target="Adapter" Name="HTTPServer">api.lifx.com</Setting>
    <Setting Target="Adapter" Name="SSLCheckServerIdentity">0</Setting>
    <Setting Target="Adapter" Name="URL">v1/lights/all/state</Setting>
    <Setting Target="Adapter" Name="Credentials">lifx</Setting>
  </Item>
</Production>
}

}
