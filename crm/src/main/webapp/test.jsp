<%--
  Created by IntelliJ IDEA.
  User: Raymond
  Date: 2021/12/12
  Time: 15:45
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
    System.out.println(basePath);



%>





<html>
<head>
    <base href="<%=basePath%>">
    <title>Title</title>

    <script type="text/javascript">

    </script>
</head>
<body>

</body>
</html>

