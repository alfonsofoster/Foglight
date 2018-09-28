// Environmenet_Info.groovy

// ***** agent type counts *****
import java.sql.*
import java.text.*

// Grab the Agent Service and list all agents
agtSvc = server["AgentService"];
agents = agtSvc.findAll();

// grab the RemoteAgentManagementService and list all remote agent managers
managerService = server["RemoteAgentManagementService"];
clients = managerService.findAllRemoteClients();

// grab the CartridgeService and list all Cartridges
cartSvc = server["CartridgeService"];
carts = cartSvc.listCartridges();

def sb = new StringBuilder();
def agentTypes = [];
def fglamVersions = [];
def cntLinux = 0;
def cntWindows = 0;
def cartList = ["DB_DB2", "DB_Oracle", "DB_SQL_Server", "DB_Sybase", "WindowsAgent"]

agents.each{ agent ->
	def agentType = agent.getTypeId();
	agentTypes.add(agentType);
}
// create a map of agent types
Map counts = agentTypes.countBy{it}

clients.each{ client ->
	def osName = client.getOSName().toString().toLowerCase();
	def clientVersion = client.getClientVersion().toString();
	
	switch (osName) {
		case "linux":
			cntLinux += 1
			break 
		case "windows":
			cntWindows += 1
			break
		default:
			cntOther += 1
	}

	if (! fglamVersions.contains(clientVersion)) {
		fglamVersions.add(clientVersion);
	}
}

carts.each{ cart ->
	def name = cart.getName().toString();
	def status = cart.getCartridgeStatus().toString();
	if (cartList.contains(name) && status == "ACTIVATED"){
		def version = cart.getVersion();
		sb.append("Cartridge Name = ${name}\n");
		sb.append("Cartridge Version = ${version}\n");
	}
}

sb.append("Agent Counts = ${counts}\n");
sb.append("Agent Managers in Linux = ${cntLinux}\n");
sb.append("Agent Managers in Windows = ${cntWindows}\n");
sb.append("Fglam Versions = ${fglamVersions}\n");
return sb;
