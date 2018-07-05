return {
    TEST = true,
    version = "1.0.0",
	--集群地址配置
	cluster = {
		node1 = "127.0.0.1:2528", 
		--node2 = "127.0.0.1:2529",
	},
	--默认通信协议
	prototype = "tcp",  --tcp/ws
	protopack = "pbc",   --pbc/json
	--各个服务配置
	service = {
		--debug_console服务
		debug_console = {
			[1] = {port=8701, node = "node1"},
			--[2] = {port=8702, node = "node2"},
		},
		--game服务
		game = {
			[1] = {node = "node1"},
			--[2] = {node = "node2"},
		},
		--gateway服务
		gateway_common = {maxclient = 1024, nodelay = true},
		gateway = {
			--[1] = {port = 8798,  node = "node1", prototype="tcp", protopack="pbc"},
			[1] = {port = 8798,  node = "node1", },
			[2] = {port = 8799,  node = "node1", prototype="ws", protopack="pbc"},
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
        login_common = {
            mode="test",
            test={},
        },
		--login服务
		login = {
			[1] = {node = "node1"},
			--[2] = {node = "node2"},
		},
		--dbproxy服务
		dbproxy_common = {
			accountdb = {db_type = "mongodb", host = "127.0.0.1", db_name = "account"}, --host,port,username,password,authmod
			gamedb = {db_type = "mongodb", host = "127.0.0.1", db_name = "game"},
			globaldb = {db_type = "mongodb", host = "127.0.0.1", db_name = "global"},
			logdb = {db_type = "mongodb", host = "127.0.0.1", db_name = "log"},
		},
		dbproxy = {
			[1] = {node = "node1"},
			[2] = {node = "node1"},
		},
        --scene服务
        scene = {
            [1] = "node1",
            --[2] = "node2",
        },
		--host服务
		host_common = {
			console = {node = "node1", port = 8002},
		}
    },
}

