#!/usr/bin/expect
set timeout 20
set ip 127.0.0.1
set port 8701


spawn telnet $ip $port
expect "'^]'."
sleep .1

#gameȫ��


#gameĳ��ģ��
send "reload game game.example\r"
expect "<CMD OK>"

#ȫ������
#send "resetup\r"
#expect "<CMD OK>"

#��������
send "resetup item\r"
expect "<CMD OK>"

exit

##reload wsagent agent.agent_room

