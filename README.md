# zServer
zServer��һ�׻���skynet��ͨ�÷���˿�ܣ����Ϊ���Ϸ�������Ϸ�Ŀ�ܣ������ơ�xx����ս��

##�����뷽����
����Ŀ¼��make

##��Ŀ¼���ܡ�
* config		��Ϸ����
* etc    		��������
* luaclib		c���Կ�
* lualib		lua��
* lualib-src	c���Կ�Դ��
* mod			��Ϸ�߼�
* service		����������߼�
* run			����������Ϣ
* skynet		skynetԭ�����иĶ���
* log			��־Ŀ¼
* test		���Գ���


##�����к�ʾ����
ʾ��1 echo
	�����./start.sh �������з���ˣ����׶Σ�
	�ͻ��� cd test ../skynet/3rd/lua/lua 1-echo.lua
ʾ��2 name
	���ݿⱣ�����
ʾ��3 chat	
ʾ��4 movegame	
	���в��Կͻ��� ������Ϸ http://123.207.111.118/move/
ʾ��5 ������
ʾ��6 ��־
	1 �޸�config��log_level��������־����
	2 ��ʹ��../start.sh -D����־�ļ���userlog
	3 telnet 127.0.0.1 8701��logon/logoff address ��¼һ���������е�������Ϣ��log�ļ�����
ʾ��7 �����ȸ��£������ȸ���
	��ʾ��1��ʾ��5�����ã��ȸ���������
ʾ��8 ���а�
	���а��ѯ���������а���ʾglobal��������
ʾ��9 ���ݿ��������
        ʹ��ʾ��1��¼���ر����ݿ⣬���ԣ��ؿ����ݿ⣬����
ʾ��10 xx��Ϸ
	
	
ע�⣺
�ȸ���ģ���޸��������ļ���������skynet��Ӧ�ð���һ���ֳ����
skynet/lualib/debug.lua
skynet/service/debug_console.lua
skynet/service/launcher.lua

�����ԸĽ���
[�Ż�]game�ĳ�agentpool�����ģ����迪��
[�Ż�]������require���ο�skynet/lualib/debug.luaע�͵���reload.loadmod("reloadlist")
[�Ż�]�¼�ϵͳ��login/loginout��
[�Ż�]��Ҵ洢����һ��redis
[�Ż�]call��Э��������Ϊ�õ�����ģ��
[����]�ط�����
[����]on����˿��� on�رյȷ�������
[�Ż�]gate login game dbproxy��ͬһ�ڵ���
���ܲ���



�Ѿ����ֵ�ע���
bson��bson���key����Ϊstring����ȡʱҪtonumber����










