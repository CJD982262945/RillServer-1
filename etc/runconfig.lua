return {
    TEST = true,
    version = "1.0.0",
	--集群地址配置
	cluster = {
		node1 = "127.0.0.1:2528", 
		node2 = "127.0.0.1:2529",
	},
	--通信协议
	prototype = "ws",  --tcp/ws
	protopack = "json",   --pb/json
	--各个服务配置
	service = {
		--debug_console服务
		debug_console = {
			[1] = {port=8701, node = "node1"},
			[2] = {port=8702, node = "node2"},
		},
		--game服务
		game = {
			[1] = {node = "node1"},
			[2] = {node = "node2"},
		},
		--gateway服务
		gateway_common = {maxclient = 1024, nodelay = true},
		gateway = {
			[1] = {port = 8798,  node = "node2"},
			[2] = {port = 8799,  node = "node1"},
		},
		--global服务
		global = {
			[1] = {node = "node1"},
			[2] = {node = "node1"},
		},
		--center服务
		center = {
			[1] = {node = "node1"},
			[2] = {node = "node1"},
		},
		--login服务
		login = {
			[1] = {node = "node1"},
			[2] = {node = "node2"},
		},
		--dbproxy服务
		dbproxy_common = {
			accountdb = {db_type = "mongodb", host = "127.0.0.1", db_name = "account"}, --host,port,username,password,authmod
			gamedb = {db_type = "mongodb", host = "127.0.0.1", db_name = "test"},
			globaldb = {db_type = "mongodb", host = "127.0.0.1", db_name = "global"},
			logdb = {db_type = "mongodb", host = "127.0.0.1", db_name = "log"},
		},
		dbproxy = {
			[1] = {node = "node1"},
			[2] = {node = "node1"},
		},
		--host服务
		host_common = {
			web = {node = "node1", port = 8111},
			console = {node = "node1", port = 8002}, --尚未实现
		}
    },
	--玩家数据表配置
	playerdata = {
		baseinfo = true,
	},
	--具体各个功能逻辑的配置
	movegame = {
		global = {
			[1] = "global1",
			[2] = "global2",
		},
	},
	queryboard = {
		global = {
			[1] = "global1",
			--不支持分布式
		},
	},
	lifegame = {
		global = {
			[1] = "global1",
			[2] = "global1",
		},
		mgr = "global1",
	}
}
