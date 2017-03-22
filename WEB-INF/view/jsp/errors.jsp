<%-- sso登陆后，应用通过sso登陆，应用没有注册的错误页面 --%>

<%@ page pageEncoding="UTF-8" %>

<jsp:directive.include file="default/ui/includes/top.jsp" />
  <div id="msg" class="errors">
    <p><spring:message code="screen.unavailable.heading" /></p>
  </div>
<jsp:directive.include file="default/ui/includes/bottom.jsp" />
