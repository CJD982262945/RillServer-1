# RillServer
RillServer��һ�׻���skynet��ͨ����Ϸ����˿�ܣ��ʺϴ���ս�����ơ�RPG�����Եȶ������͵���Ϸ����������Ƴ�����Ϊ�˼������߿���Ч�ʣ�������Ϸ�����ɱ���

��Ҫȡ�����֣�RillС�ӣ��������ͨ���裬�������ɺ�������ʱ�գ����������

##����ܹ�
RillServer���ô�ͳc++�������ļܹ�������

###�ܹ�ͼ
����ܹ�����ͼ��ʾ����ɫ�������skynet�ڵ㣬��ɫ����������һ���ڵ�Ὺ��game��global��login�ȶ��ַ��񡣻�ɫ�������gateway��ת����Χ�����ͻ�������ĳ���ڵ��gateway����gatewayֻ�Ὣ��Ϣת�����ýڵ��µ�login��game��
![Alt text](./doc/img/1.jpg)

###��������Ĺ��ܣ�

* gateway���ţ��ͻ���ֻ����gateway����������δ��¼��gateway�����Ϣ����login�������¼�ɹ���ת����game
* login����¼���������¼�߼�
* game����Ϸ������������߼�
* center�����ķ�����¼��ҵ�¼״̬����Ϣ
* global	ȫ�ַ������ڴ�ʵ�ֿ��ս�ȹ���
* dbproxy�����ݿ����ʹ�÷���ֱ�Ӳ������ݿ⣬ֻ����dbproxy
* host�����������ڼ�Ⱥ���ƣ����ȸ��¡��ط����Լ�web
> ps��
> 1��һ���ڵ��gateֻ�����Ӹýڵ��login��game��login��game�������ӿ�ڵ��center��global��dbproxy��
> 2����ʱδʵ��cache�㡣
> 3����ܾ������޸�skynet���룬�Ա��������������Щ������Ҫ���뵽ԭ�����������ʱ������޸���һ���֡���Щ�޸Ĳ����漰���Ĳ��֣�һ�������ӿ���̨���ܡ�������skynet��Ӧ�ð���һ���ֳ������
>skynet/lualib/debug.lua
>skynet/service/debug_console.lua
>skynet/service/launcher.lua

###�ļ�Ŀ¼
* config���߻������ļ���
* etc�����������ļ���
* luaclib��һЩcģ��, .so�ļ�
* lualib��luaģ��
* lualib-src��cģ�����
* mod����Ϸ�߼�ģ��
* proto��protobuf�ļ�����ʹ��pbЭ����Ҫ��proto�ļ���������
* run����¼pid����Ϣ
* service��������ڵ�ַ������������ȡmod���Ӧģ��
* skynet��skynet��ܣ����ﾡ���ٸĶ������Ա��������
* test������

##����
�����½ڽ�����ܿ����������Լ�ʵ��echo����������̫��Ϥskynet�ͷ���˱�̣���ӭ�ο� [��Ϸ�о�Ժ](https://zhuanlan.zhihu.com/pyluo) �е����¡�

###����

���ش������Ҫ��̳���ֻ��Ҫ����Ŀ¼�µ�./make.sh all���ɡ������Ĭ��ʹ��websocket+json��ͨ��Э�顣

> **protobufЭ��**
> ֻҪ�����þ��ܹ�֧��tcp��ͷ���ֽڴ����ȣ�+protobuf�ĸ�ʽ�� �����ʹ��LuaPbIntf����protobufЭ�飬���ʹ��protobufЭ�飬��Ҫ��װprotobuf���������£�
>  yum nstall autoconf 
>  yum install automake 
>  yum install libtool
>  yum install glibc-headers gcc-c++
>  cd lualib-src/LuaPbIntf/third_party/protobuf
> ./autogen.sh
>  ./configure CFLAGS="-fPIC"  CXXFLAGS="-fPIC" 
>  make 
>  make install
>  vim /etc/profile�����  LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
>   ldconfig
>
>Դ���ж�LuaPbIntf���иĶ�������ӦЭ���µ�protobuf�������

###����
�޸�etc/runconfig.lua�еĶ˿ںţ�Ȼ��ִ��./start.sh���ɿ���һ����Ϸ�ڵ㡣

###echo
������ο�ʾ��1


----

##ʾ��
* ʾ��1 echo
	     �����./start.sh �������з���ˣ����׶Σ�
	    �ͻ��� cd test ../skynet/3rd/lua/lua 1-echo.lua
* ʾ��2 name  
        ���ݿⱣ�����
* ʾ��3 chat	
* ʾ��4 movegame	
* ʾ��5 ������
* ʾ��6 ��־
* ʾ��7 �����ȸ��£������ȸ���
* ʾ��8 ���а�
	���а��ѯ���������а���ʾglobal��������
* ʾ��9 ���ݿ��������
        ʹ��ʾ��1��¼���ر����ݿ⣬���ԣ��ؿ����ݿ⣬����  
* ʾ��10 �ط�����
* ʾ��11 pbЭ��
* ʾ��12 ��ү����ս





----


##���ԸĽ�
*  [�Ż�] ���ӹ���
*  [����] ���ܲ���
*  [�Ż�] game�ĳ�agentpool�����ģ����迪��
*  [�Ż�] ��Ҵ洢����һ��redis
*  [����] web��Ȩ
*  [����] δ���ԣ�mysqldb �޸ĳ�mongodb����ʽ��
*  [�Ż�] web������ȡ
*  [�Ż�] ��ȡ�޸�skynet�Ĳ��֣���Ҫ�޸�skynet����Դ��
*  [�Ż�] ��־���Ū�ÿ�һ��
*  [�Ż�] log����
*  [�Ż�] ͬһ�˺ſ��ٵ�¼���������
*  [bug]  watch game�б�recmmad�б����ܳ���
*  [bug]  ����ս�߲����£�������syncЭ��
  

##�Ѿ����ֵ�ע���
bson��bson���key����Ϊstring����ȡʱҪtonumber����
����dataSheet��init�׶γ�ʼ������awake��start��init�׶�ǰִ�У��޸�skynet/lualib/skynet/datasheet/init.lua��querysheet����������if datasheet_svr == nil then datasheet_svr = service.query("datasheet") end


�����ĵ�
tool���ӱ���
��player��صĶ��ŵ�player�ļ��У�new load_data load_all_data save_all_data������Ϊ��ȡpb�ṹ����{playerid,pbstr}


