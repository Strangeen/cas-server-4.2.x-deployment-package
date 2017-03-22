<%-- sso没有登陆，应用通过sso登陆，应用没有注册的错误页面 --%>

<%@ page pageEncoding="UTF-8" %>

<jsp:directive.include file="includes/top.jsp" />
  <div id="msg" class="errors">
    <h2><spring:message code="screen.service.error.header" /></h2>
  </div>
<jsp:directive.include file="includes/bottom.jsp" />
