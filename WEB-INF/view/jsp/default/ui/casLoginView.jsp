<%@ page pageEncoding="UTF-8" %>

<jsp:directive.include file="includes/top.jsp" />

<p>cas是yale大学的单点登录系统开源项目，在行业中非常流行，功能也非常强大，但由于cas系统非常庞大，系统和文档版本迭代又比较多，造成各种文档和网上的教程都无法完全匹配，初次使用时的学习成本会非常大。所以出于方便后期快速使用的考虑，我对cas4.2.7进行了学习研究，在我能理解的范围内，将工作和学习中接触过的场景纳入cas进行配置，基于方便统一配置的理念，修改了原cas的一些配置文件、其存放路径和添加了部分功能，并最终打包封装成了一套<b>仅需极简配置就可以部署完成的系统包</b>。该套系统仅使用了cas的部分功能，其他功能后续会继续完善。详情参见<a href='https://<spring:message code="support" />'><spring:message code="support" /></a> & <a href='https://<spring:message code="support2" />'><spring:message code="support2" /></a></p> 
<p>UI界面去掉了cas官方版本的很多控件和样式代码，仅留下最简单的样式和必须的控件，方便快速定制</p>

<br>
<h3>下面对cas进行操作</h3>

<br><br>


<script>
// 用于密码框输入时提示大写模式已启用
function areCookiesEnabled() {
    $.cookie('cookiesEnabled', 'true');
    var value = $.cookie('cookiesEnabled');
    if (value != undefined) {
        $.removeCookie('cookiesEnabled');
        return true;
    }
    return false;
}
// 用于检测cookie是否开启
function areCookiesEnabled() {
    $.cookie('cookiesEnabled', 'true');
    var value = $.cookie('cookiesEnabled');
    if (value != undefined) {
        $.removeCookie('cookiesEnabled');
        return true;
    }
    return false;
}
$(function(){
    $('#capslock-on').hide();
    $('#password').keypress(function(e) {
        var s = String.fromCharCode( e.which );
        if ( s.toUpperCase() === s && s.toLowerCase() !== s && !e.shiftKey ) {
            $('#capslock-on').show();
        } else {
            $('#capslock-on').hide();
        }
    });
    
    if (areCookiesEnabled()) {
        $('#cookiesDisabled').hide();
    } else {
        $('#cookiesDisabled').show();
        $('#cookiesDisabled').animate({ backgroundColor: 'rgb(187,0,0)' }, 30).animate({ backgroundColor: 'rgb(255,238,221)' }, 500);
    }
})
</script>

<%-- https没有开启提示 --%>
<c:if test="${not pageContext.request.secure}">
    <div id="msg" class="errors">
        <h2><spring:message code="screen.nonsecure.title" /></h2>
        <!-- <p><spring:message code="screen.nonsecure.message" /></p> -->
    </div>
</c:if>

<%-- cookie没有启用提示 --%>
<div id="cookiesDisabled" class="errors" style="display:none;">
    <h2><spring:message code="screen.cookies.disabled.title" /></h2>
    <!-- <p><spring:message code="screen.cookies.disabled.message" /></p> -->
</div>

 
<%-- service登陆时展示service信息 --%>
<!-- <c:if test="${not empty registeredService}">
    <c:set var="registeredServiceLogo" value="images/webapp.png"/>
    <c:set var="registeredServiceName" value="${registeredService.name}"/>
    <c:set var="registeredServiceDescription" value="${registeredService.description}"/>
    
    <%-- 应该是用于全局设置 --%>
    <c:choose>
        <c:when test="${not empty mduiContext}">
            <c:if test="${not empty mduiContext.logoUrl}">
                <c:set var="registeredServiceLogo" value="${mduiContext.logoUrl}"/>
            </c:if>
            <c:set var="registeredServiceName" value="${mduiContext.displayName}"/>
            <c:set var="registeredServiceDescription" value="${mduiContext.description}"/>
        </c:when>
        <c:when test="${not empty registeredService.logo}">
            <c:set var="registeredServiceLogo" value="${registeredService.logo}"/>
        </c:when>
    </c:choose>

    <div id="serviceui" class="serviceinfo">
        <table>
            <tr>
                <td>Service LOGO</td>
                <td id="servicedesc">
                    <h1>${fn:escapeXml(registeredServiceName)}</h1>
                    <p>${fn:escapeXml(registeredServiceDescription)}</p>
                </td>
            </tr>
        </table>
    </div>
    <p/>
</c:if> -->


<%-- 登录相关控件，以及错误提示 --%>
<div class="box" id="login">
    <form:form method="post" id="fm1" commandName="${commandName}" htmlEscape="true">
    
        <%--用户名相关--%>
        <section class="row">
            <label for="username"><spring:message code="screen.welcome.label.netid" /></label>
            <input id="username" name="username" value="" />
            <%--
            <c:choose>
                <c:when test="${not empty sessionScope.openIdLocalId}">
                    <strong><c:out value="${sessionScope.openIdLocalId}" /></strong>
                    <input type="hidden" id="username" name="username" value="<c:out value="${sessionScope.openIdLocalId}" />" />
                </c:when>
                <c:otherwise>
                    <spring:message code="screen.welcome.label.netid.accesskey" var="userNameAccessKey" />
                    <form:input cssClass="required" cssErrorClass="error" id="username" size="25" tabindex="1" accesskey="${userNameAccessKey}" path="username" autocomplete="off" htmlEscape="true" />
                </c:otherwise>
            </c:choose>
            --%>
        </section>

        <%--密码相关--%>
        <section class="row">
            <label for="password"><spring:message code="screen.welcome.label.password" /></label>
            <input id="password" name="password" type="password" />
            <%--
            <spring:message code="screen.welcome.label.password.accesskey" var="passwordAccessKey" />
            <form:password cssClass="required" cssErrorClass="error" id="password" size="25" tabindex="2" path="password"  accesskey="${passwordAccessKey}" htmlEscape="true" autocomplete="off" />
            --%>
            <%--大写提示--%>
            <span id="capslock-on" style="display:none;"><p><spring:message code="screen.capslock.on" /></p></span>
        </section>
        
        <%-- 帐号密码错误提示 --%>
        <form:errors path="*" id="msg" cssClass="errors" element="div" htmlEscape="false" />
        
        <%-- 记住账号15天内无需登录的勾选框 --%>        
        <input type="checkbox" name="rememberMe" id="rememberMe" value="true" tabindex="5"  />
        <label for="rememberMe"><spring:message code="screen.rememberme.checkbox.title" arguments="15" /></label>
        

        <section class="row btn-row">
           
            <input type="hidden" name="execution" value="${flowExecutionKey}" />
            <input type="hidden" name="_eventId" value="submit" />

            <input class="btn-submit" name="submit" accesskey="l" value="<spring:message code="screen.welcome.button.login" />" tabindex="6" type="submit" />
            <input class="btn-reset" name="reset" accesskey="c" value="<spring:message code="screen.welcome.button.clear" />" tabindex="7" type="reset" />
        </section>
    </form:form>
</div>

<jsp:directive.include file="includes/bottom.jsp" />
