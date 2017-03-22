<%-- 退出成功页面 --%>

<%-- 暂时不会Spring webflow，所以按上述代码实现退出后重定向到登陆页面 --%>


<%@ page pageEncoding="UTF-8" %>

<%
String lgoRedirUrl = request.getParameter("service");
if (lgoRedirUrl != null && !"".equals(lgoRedirUrl)) {
	response.sendRedirect(lgoRedirUrl);
} else {
	response.sendRedirect("/cas");
}
%>


