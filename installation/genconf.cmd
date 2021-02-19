set CJDNS_CONF="cjdroute.conf"
rem PEER_ADD_SCRIPT="addPublicPeers.vbs"
set PEER_ADD_SCRIPT="add_peers_to_conf.vbs"

if exist %CJDNS_CONF% (
	rem Not clobbering config
) else (
	cjdroute.exe --genconf > %CJDNS_CONF%
	rem 
	rem addPublicPeers
	if exist %PEER_ADD_SCRIPT% (
		rem Add peers to config file
		cscript %PEER_ADD_SCRIPT%
	)
)
