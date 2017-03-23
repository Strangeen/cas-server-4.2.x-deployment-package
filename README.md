
# 概述

cas是yale大学的单点登录系统开源项目，在行业中非常流行，功能也非常强大，但由于cas系统非常庞大，系统和文档版本迭代又比较多，造成各种文档和网上的教程都无法完全匹配，初次使用时的学习成本会非常大。所以出于方便后期快速使用的考虑，我对cas4.2.7进行了学习研究，在我能理解的范围内，将工作和学习中接触过的场景纳入cas进行配置，基于方便统一配置的理念，基于cas4.2.7修改了一些配置文件、文件存放路径以及添加了部分功能，并最终打包封装成了一套**仅需极简配置就可以部署完成的运行于下述性能情况的系统部署包**：

# 性能

1. 使用**普通认证模式**，非代理认证模式(Proxy Authentication)

2. 使用**cas协议3.0**认证(cas protocol 3.0)

3. 使用**JDBC验证**用户信息，如Mysql/Oracle数据库（默认mysql，Oracle需要导入jar包并配置dataSource bean）

* **注：**

    - 我现在暂时无法理解和清楚代理认证模式的业务场景，所以只做了普通认证模式的配置
 
    - 后期再增加认证协议(Authentication Protocol)，如OAuth等
 
    - 后期再增加其他验证用户信息方式，如LDAP等

该套系统部署包仅使用了cas4.2.7的部分功能，其他功能后续会继续完善，使用过程中任何问题请在[cas server4.2.x部署包1.0.0发布](https://www.juwends.com/tech/java/cas-server4-2-x_deployment_package_1-0-0.html)留言

# Quick Start

将部署包文件下载到本地，放入tomcat的`webapp/cas`文件夹中，按如下方法做基本配置：

### dataSource配置
        
配置`/WEB-INF/cas.properties`文件：
```properties
cas.jdbc.authn.search.password=password
cas.jdbc.authn.search.user=username
cas.jdbc.authn.search.table=user_account
···
database.driverClass=com.mysql.jdbc.Driver
database.url=jdbc:mysql://127.0.0.1:3306/cas_test
database.user=root
database.password=root
```
- `cas.jdbc.authn.search.password`为登录信息验证的密码字段名，如：password

- `cas.jdbc.authn.search.user`为登录信息验证的用户名字段名，如：username

- `cas.jdbc.authn.search.table`为登录信息验证的数据表名，如：user_account

- `database.driverClass`为数据库驱动名称，默认为`com.mysql.jdbc.Driver`

- `database.url`为数据库连接url，如：jdbc:mysql://127.0.0.1:3306/cas_test

- `database.user`为数据库连接用户名，如：root

- `database.password`为数据库连接密码，如：root


### http/https配置

默认已配置为：部署http，部署路径`/cas`，如现状满足就不需要修改配置了。如果需要部署为https或更改部署路径，查看`更多配置` - `3. http/https部署`进行配置


基本配置完成，打开浏览器输入`localhost/cas`就可以登陆cas了

---

# 更多配置

### 1. 登陆验证

- #### 描述
    使用JDBC验证，默认密码采用MD5加密算法+BASE64格式化存储在数据库中，编码UTF-8

- #### 配置
    配置要点：dataSource数据源，验证参数及dataSource参数，验证加密密码方式
      
    1. **配置dataSource数据源**（默认已配置c3p0）
    
        `/WEB-INF/loginValidationContext.xml`：
        ```xml
        <bean id="dataSource"
			class="com.mchange.v2.c3p0.ComboPooledDataSource"
			p:driverClass="${database.driverClass}"
			p:jdbcUrl="${database.url}"
			p:user="${database.user}"
			p:password="${database.password}"
			p:initialPoolSize="${database.pool.minSize}"
			p:minPoolSize="${database.pool.minSize}"
			p:maxPoolSize="${database.pool.maxSize}"
			p:maxIdleTimeExcessConnections="${database.pool.maxIdleTime}"
			p:checkoutTimeout="${database.pool.maxWait}"
			p:acquireIncrement="${database.pool.acquireIncrement}"
			p:acquireRetryAttempts="${database.pool.acquireRetryAttempts}"
			p:acquireRetryDelay="${database.pool.acquireRetryDelay}"
			p:idleConnectionTestPeriod="${database.pool.idleConnectionTestPeriod}"
			p:preferredTestQuery="${database.pool.connectionHealthQuery}"/>
        ```
        其他数据源修改`<bean>`标签的`class`属性
    
    2. **配置验证参数及dataSource参数**（需要自定义）
    
        `/WEB-INF/cas.properties`：
        ```properties
        cas.jdbc.authn.search.password=password
        cas.jdbc.authn.search.user=username
        cas.jdbc.authn.search.table=user_account
        
        # == Basic database connection pool configuration ==
        database.driverClass=com.mysql.jdbc.Driver
        database.url=jdbc:mysql://127.0.0.1:3306/cas_test
        database.user=root
        database.password=root
        database.pool.minSize=6
        database.pool.maxSize=18
        # Maximum amount of time to wait in ms for a connection to become
        # available when the pool is exhausted
        database.pool.maxWait=10000
        # Amount of time in seconds after which idle connections
        # in excess of minimum size are pruned.
        database.pool.maxIdleTime=120
        # Number of connections to obtain on pool exhaustion condition.
        # The maximum pool size is always respected when acquiring
        # new connections.
        database.pool.acquireIncrement=6
        # == Connection testing settings ==
        # Period in s at which a health query will be issued on idle
        # connections to determine connection liveliness.
        database.pool.idleConnectionTestPeriod=30
        # Query executed periodically to test health
        database.pool.connectionHealthQuery=select 1
        # == Database recovery settings ==
        # Number of times to retry acquiring a _new_ connection
        # when an error is encountered during acquisition.
        database.pool.acquireRetryAttempts=5
        # Amount of time in ms to wait between successive aquire retry attempts.
        database.pool.acquireRetryDelay=2000
        ```
        - `cas.jdbc.authn.search.table`为登录信息验证的数据表名，如：user_account
        
        - `cas.jdbc.authn.search.user`为登录信息验证的用户名字段名，如：username
        
        - `cas.jdbc.authn.search.password`为登录信息验证的密码字段名，如：password
        
        - `database.driverClass`为数据库驱动名称，默认为`com.mysql.jdbc.Driver`
        
        - `database.url`为数据库连接url，如：jdbc:mysql://127.0.0.1:3306/cas_test
        
        - `database.user`为数据库连接用户名，如：root
        
        - `database.password`为数据库连接密码，如：root
        
        - 其他按需配置
    
    3. **配置验证加密密码方式**（默认已配置MD5加密算法+BASE64格式化，编码UTF-8）
        
        1. 配置加密算法和密码编码
        
            `/WEB-INF/cas.properties`：
            ```
            cas.authn.password.encoding.char=UTF-8
            cas.authn.password.encoding.alg=MD5
            ```
            - `cas.authn.password.encoding.char`为密码编码，默认`UTF-8`
            
            - `cas.authn.password.encoding.alg`为加密算法，默认`MD5`，官方默认配置为`SHA-256`
        
        2. 配置加密密码格式化方式
        
            `/WEB-INF/spring-configuration/deployerConfigContext.xml`:
            ```
            <alias name="base64TextPasswordEncoder" alias="passwordEncoder" />
            ```
            `<alias>`标签的`name`属性默认为`base64TextPasswordEncoder`
            
            该bean由我重写官方代码实现`注释1`，代码在`cas-server-core-authentication-4.2.7-addition-1.0.jar`的`online.dinghuiye.cas.authentication.handler`包中，源码参看：[cas-server-core-authentication-4.2.7-addition](https://github.com/Strangeen/cas-server-core-authentication-4.2.7-addition)
            
            如需自定义其他格式化方式，可以按如下步骤编码并配置：
            1. 自定义类继承`online.dinghuiye.cas.authentication.handler.AbstractTextPasswordEncoder`实现格式化
            
            2. 声明上述自定义类为bean
            
            3. 修改上述`<alias>`标签`name`属性为自定义声明的bean名称(ID)


### 2. Attribute传递(Attribute Release) 和 Service注册(Service Registry)

- #### 描述
    该功能用于应用(service)客户端(cas client)通过cas server登陆后获取cas server提供的公开信息，配置cas client之前必须修改下述配置，否则会出现无法跳转会cas client等问题

- #### 配置
    配置要点：信息查询sql，字段传递信息，应用客户端信息（service注册）

    1. **配置信息查询sql**（需要自定义）
    
        `/WEB-INF/loginValidationContext.xml`：
        1. 修改sql：
            ```xml
            <constructor-arg 
                index="1" 
                value="select * from user_account a left join user_info u on a.id = u.account_id where {0}" />
            ```
            - `<constructor-arg>`标签`value`属性为用户登陆账户密码查询sql，`{0}`需要保留在`where`之后，sql可以使用join查询
            
            - 默认sql对应的表字段：
                表user_account
                ```sql
                id int,
                username varchar,
                password varchar,
                is_start int
                ```
                表user_info
                ```sql
                id int,
                real_name varchar,
                age int,
                sex varchar,
                company varchar,
                telephone varchar,
                account_id int
                ```
        2. 修改where条件值
            ```xml
            <property name="queryAttributeMapping">
                <map>
                    <!--key页面form表单用户名input控件的name值，value数据库字段名-->
                    <entry key="username" value="username" />
            ···
            ```
            - `<entry>`标签的`key`属性为表单中用户名input控件的name值
            
            - `<entry>`标签的`value`属性为数据库对应的字段名
    
    2. **配置字段传递信息**（需要自定义）
    
        `/WEB-INF/loginValidationContext.xml`：
        ```xml
        <property name="resultAttributeMapping">
            <map>
                <!--key数据库字段名，value返回给页面该值的变量名-->
                <entry key="username" value="account" />
                <!--
                <entry key="real_name" value="name" />
                <entry key="age" value="age" />
                <entry key="sex" value="sex" />
                <entry key="company" value="co" />
                <entry key="telephone" value="phone" />
                -->
        ···
        ```
        - `<entry>`标签的`key`属性为数据库对应的字段名
        
        - `<entry>`标签的`value`属性为传给客户端的代表该值的变量名，只有配置了才会传递给客户端
        
        - 注释部分根据需求自定义配置
    
    3. **配置应用客户端信息(Service Registry)**（默认已配置所有http/https应用均可通过）
        
        - 描述：
            对于需要通过cas server进行单点登录的客户端，cas server可以配置限制，即某些指定url的客户端才可进行单点登录，配置地址在`/WEB-INF/services/`下以`JSON`方式保存客户端信息和配置，该配置文件可以实时修改，修改后不需要重启cas server，其会在修改后等待最多60秒后被扫描到并生效，因此，建议一个客户端配置一个明确的`JSON`文件和url，当有新增客户端时，进行实时配置
        
        - 配置：
        
            `/WEB-INF/services/`下：
        
            1. 删除文件`service-sample-delete-when-deploy.json`
            
            2. 复制`localhost-1.json`，更改为自定义文件名称，如cas client部署的域名或ip
            
            3. 修改配置：
                ```
                ···
                  "serviceId" : "^http://localhost:8081/mywebapp/.*",
                ···
                  "id" : 10000001,
                ···
                    "allowedAttributes" : [ "java.util.ArrayList", [ "account", "name", "sex", "co", "age", "phone" ] ],
                ···
                ```
                - `serviceId`为客户端url，正则表达式表示
                
                - `id`为客户端id，必须为每个客户端配置唯一id
                
                - `allowedAttributes`为允许传递给客户端的Attribute列表，在`loginValidationContext.xml`中配置的Attribute传递是作为最多情况，即最多传递的Attribute，同时`loginValidationContext.xml`中的配置也是不能实时修改的，所以cas server给出了在配置客户端时可以再次限制Attribute传递并可以实时修改的设计。具体配置为修改`列表[ "account", "name", "sex", "co", "age", "phone" ]`中的值为`loginValidationContext.xml`中`<property name="resultAttributeMapping">`标签下`<entry>`标签的`value`属性值，在`列表`中的值将会传递给客户端
    
        * 注：该步骤与客户端(cas client)密切相关，客户端必须使用cas portocol3.0进行登陆验证，否则无法正常使用Attribute传递
    

### 3. http/https部署

- #### 描述
    cas官方推荐使用https部署cas server，但是鉴于大多数情况下多是使用http部署的，所以我整理的部署包默认采用http

- #### 配置
    `/WEB-INF/cas.properties`：
    ```properties
    tgc.secure=false
    ···
    tgc.path=/cas
    ```
    - `tgc.secure`设置`false`使用http，设置`true`使用https
    
    - `tgc.path`为cas部署的url相对路径，如cas部署的网络地址为localhost:8080/cas，该值应设置为`/cas`
    

### 4. 单点登出

- #### 描述
    该功能用于控制cas server退出后，将所有应用(service)客户端(cas client)都退出，默认开启，该功能与客户端(cas client)密切相关

- #### 配置
    
    `/WEB-INF/cas.properties`：
    ```properties
    # To turn off all back channel SLO requests set this to true
    # slo.callbacks.disabled=false
    ```
    - `slo.callbacks.disabled`设置为`true`将关闭单点登出功能（需要配置要去掉注释`#`）
    

### 5. 登陆状态超时(TGT超时)

- #### 描述：
    默认为TGT闲置2小时超时登出，即超过2小时不操作则自动退出

- #### 配置：
    配置要点：超时模式，超时时间

    1. **配置超时模式**（默认已配置）
    
        `/WEB-INF/deployerConfigContext.xml`
        ```xml
        <alias name="ticketGrantingTicketExpirationPolicy" alias="grantingTicketExpirationPolicy" />
        ```
        - `name`属性为超时模式bean名称，默认采用`ticketGrantingTicketExpirationPolicy`，可以配置生命周期超时和类似session时效的闲置超时（即最后一次操作不满足超时条件不清除）
        
        - `name`属性可选配置：`timeoutExpirationPolicy`，同上，但只能设置闲置超时
        
        - `name`属性可选配置：`hardTimeoutExpirationPolicy`，强制超时，即超时就清除，不论是否正在操作
        
    2. **配置超时时间**（默认已配置2小时）
    
        1. 默认配置：
    
            `/WEB-INF/cas.properties`：
            ```properties
            tgt.maxTimeToLiveInSeconds=28800
            tgt.timeToKillInSeconds=7200
            ```
            - `tgt.maxTimeToLiveInSeconds`为生命周期超时时间，单位为秒，默认28800秒，即8小时
            
            - `tgt.timeToKillInSeconds`为闲置超时时间，单位为秒，默认为7200秒，即2小时
        
        2. `name`标签选择`timeoutExpirationPolicy`，超时配置为：
            
            `/WEB-INF/cas.properties`：
            ```
            tgt.timeout.maxTimeToLiveInSeconds=7200
            ```
            - `tgt.timeout.maxTimeToLiveInSeconds`为闲置超时时间，单位为秒，默认为7200秒，即2小时
        
        3. `name`标签选择`hardTimeoutExpirationPolicy`，超时配置为：
        
            `/WEB-INF/cas.properties`：
            ```
            tgt.timeout.hard.maxTimeToLiveInSeconds=28800
            ```
            - `tgt.timeout.hard.maxTimeToLiveInSeconds`为生命周期超时时间，单位为秒，默认28800秒，即8小时
    
    3. **配置TGT清除扫描间隔时间**（默认已配置5分钟）
        
        `/WEB-INF/cas.properties`：
        ```
        ticket.registry.cleaner.repeatinterval=300
        ```
        - `ticket.registry.cleaner.repeatinterval`为扫描间隔，单位为秒，默认300秒，即5分钟
        

### 6. cookie超时(TGC超时)

- #### 描述：

    TGC默认配置2小时，TGC与TGT作用是配合用于记录登陆状态的，TGC保存在浏览器端，TGT保存在服务端，作用类似session

    当TGT失效后即退出登陆，当TGC失效后，无法维持登陆状态，但如果TGT没有失效，实际是没有真正退出，只是无法找到TGT无法维持登陆状态

- #### 配置：

    `/WEB-INF/cas.properties`：
    ```
    tgc.maxAge=7200
    ```
    - `tgc.maxAge`为TGC超时时间，单位为秒，默认7200秒，即2小时
 


### 7. ST验证超时

- #### 描述：

    ST用于cas client验证TGT登陆状态，出于安全考虑和验证考虑，超时时间需要慎重，默认使用官方配置10秒

- #### 配置：
    ```
    # st.timeToKillInSeconds=10
    ```
    - `st.timeToKillInSeconds`为超时时间，秒为单位，默认为10秒（需要配置要去掉注释`#`）


### 8. UI界面

- #### 描述：

    精简cas官方UI，默认保留最基本页面，即登陆和跳转页面。其它页面如监控和统计页面后期继续研究后再加入部署包
    
- #### 配置：
    - `/WEB-INF/view/jsp/`：

        - `errors.jsp` 
            
            server后台报错后显示的页面，一般会出现的错误是：service登录后，应用(service)通过sso登登录，但没有注册该应用的错误
    
    - `/WEB-INF/view/jsp/default/ui/`：

        - `casLoginView.jsp`
            
            登录界面jsp页面，包括登陆失败提示
            
        - `casGenericSuccessView.jsp`
            
            登录成功后执行的jsp页面
    
        - `casLogoutView.jsp`
            
            登出成功后执行的jsp页面
    
        - `serviceErrorView.jsp`
            
            service发生错误的页面，一般会出现错误是：应用(service)没有登录，通过sso登登录，但没有注册该应用的错误
        
    - `/WEB-INF/view/jsp/default/ui/includes/`：

        - `top.jsp`
            
            头部公共jsp页面
    
        - `bottom.jsp`
            
            尾部公共jsp页面


### 9. Logger

- #### 描述：

    日志记录，默认官方配置的记录点，自行按需配置，默认logs保存在`/WEB-INF/logs`中
    
- #### 配置：

    `/WEB-INF/classes/log4j2.xml`
    

### 10. 登出

- #### 描述：
    
    默认配置为当cas server系统退出时，有指定跳转页面则跳转到指定页面，否则执行`casLogoutView.jsp`，指定页面即`/logout`的`service`参数，如登出url为：`http://server/logout?service=client`，登出后，浏览器跳转到`client`

- #### 配置：
    
    `/WEB-INF/cas.properties`：
    ```
    cas.logout.followServiceRedirects=true
    ```
    - `cas.logout.followServiceRedirects`配置为`true`，`/logout`带有`service`参数则跳转到参数地址，否则执行`casLogoutView.jsp`（默认）
    
    - `cas.logout.followServiceRedirects`配置为`false`，执行`casLogoutView.jsp`
    
* 注：`service`参数需要使用unicode编码
    
---

# 附A 注释解释

### 注释1

官方密码加密验证模式：MD5+官方实现格式算法，格式算法代码在`cas-server-core-authentication-4.2.7.jar`中`org.jasig.cas.authentication.handler`类中实现，下面列出代码：
```java
private static String getFormattedText(final byte[] bytes) {
    final StringBuilder buf = new StringBuilder(bytes.length * 2);
    
    for (int j = 0; j < bytes.length; j++) {
        buf.append(HEX_DIGITS[(bytes[j] >> HEX_RIGHT_SHIFT_COEFFICIENT) & HEX_HIGH_BITS_BITWISE_FLAG]);
        buf.append(HEX_DIGITS[bytes[j] & HEX_HIGH_BITS_BITWISE_FLAG]);
    }
    return buf.toString();
}
```

---

# 附B 配置文件位置配置

### 1. /WEB-INF/spring-configuration/deployerConfigContext.xml
`/WEB-INF/web.xml`：
```xml
<context-param>
    <param-name>contextConfigLocation</param-name>
    <param-value>
        /WEB-INF/spring-configuration/*.xml
···
```

### 2. /WEB-INF/cas.properties
`/WEB-INF/spring-configuration/propertyFileConfigurer.xml`：
```xml
<util:properties id="casProperties" location="classpath:../cas.properties" />
```
注：除了使用`classpath`作为相对路径，还可以使用`file`，`file`是以tomcat的运行文件`catalina.bat(.sh)`文件位置为相对路径的，即`/bin/`目录，后面的配置采用相同的机制


### 3. /WEB-INF/services/
`/WEB-INF/classes/cas.properties`：
```
service.registry.config.location=classpath:../services
```


### 4. /WEB-INF/classes/log4j2.xml
默认配置为/WEB-INF/classes/log4j2.xml，如需更改需要向JVM运行实例(JVM runtime instance)添加-D参数，仅以Tomcat为例：
tomcat_folder/bin/下：
- #### windows
    `catalina.bat`：
    ```
    rem ----- Execute The Requested Command ---------------------------------------
    ```
    下面添加:
    ```
    set "JAVA_OPTS=%JAVA_OPTS% -Dlog4j.configurationFile=%CATALINA_BASE%\webapps\cas\WEB-INF\log4j2.xml"
    ```
- #### linux
    `catalina.sh`：
    ```
    # ----- Execute The Requested Command -----------------------------------------
    ```
    下面添加:
    ```
    JAVA_OPTS="$JAVA_OPTS -Dlog4j.configurationFile=$CATALINA_BASE/webapps/cas/WEB-INF/log4j2.xml"
    ```

### 5. /WEB-INF/logs/*.log
`/WEB-INF/classes/log4j2.xml`：
```
<RollingFile name="file" 
    fileName="../webapps/cas/WEB-INF/logs/cas.log" append="true"
    filePattern="../webapps/cas/WEB-INF/logs/cas-%d{yyyy-MM-dd-HH}-%i.log">
···
<RollingFile name="auditlogfile"     
    fileName="../webapps/cas/WEB-INF/logs/cas_audit.log" append="true" 
    filePattern="../webapps/cas/WEB-INF/logs/cas_audit-%d{yyyy-MM-dd-HH}-%i.log">
···
<RollingFile name="perfFileAppender" 
    fileName="../webapps/cas/WEB-INF/logs/perfStats.log" append="true"
    filePattern="../webapps/cas/WEB-INF/logs/perfStats-%d{yyyy-MM-dd-HH}-%i.log">
```


### 6. /WEB-INF/spring-configuration/propertyFileConfigurer.xml
`/WEB-INF/spring-configuration/cas-servlet.xml`：
```
<import resource="propertyFileConfigurer.xml"/>
```

