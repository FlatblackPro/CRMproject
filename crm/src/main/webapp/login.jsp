<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
//拿到的basePath: http://localhost:8080/crm/
String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
	//System.out.println(basePath);
%>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">
<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
</head>


<script type="text/javascript">
	$(function () {
		//防止登录窗口仅在右侧窗口弹出：
		if (window.top != window.self){
			window.top.location = window.self.location;
		}
		
		//通过focus，让页面加载完毕后，光标在登录窗口中。
		$("#loginAct").focus();
		//用户点击登录后，前端页面开始验证：
		$("#loginBtn").click(function () {
			//取得用户的输入
			var loginAct = $("#loginAct").val();
			var loginPwd = $("#loginPwd").val();
			//进行业务判断：
			//情况1：用户名密码空：
			if ("" == loginAct || "" == loginPwd){
				//此时弹出提示，告诉用户用户名密码不能为空。
				$("#msg").html("用户名和密码不能为空！");
			}
			//情况2：有用户名密码：
			else{
				/*如果存在用户名和密码，那么将用户名和密码通过ajax请求，发送到服务器，由服务器打回来的数据进行判断：
				  1. 拿flag：表示用户名密码是否正确。
				  2. 由于并不确定用户是否一定是账号密码的原因导致登录失败，因此还要拿到用户登录失败的原因。
				  前端需要拿到的数据：data = {"success":"true/false", "msg":"登录失败的理由"}
				 */
				$.ajax({
					url:"settings/user/login.do",
					dataType:"json",
					type:"post",
					data:{
						"loginAct":loginAct,
						"loginPwd":loginPwd
					},
					success:function (resp) {
						/*
						如果登录成功，跳转到主页面；
						如果登录失败，说清楚失败的原因。
						 */
						if (resp.success){ //loginSuccess待后端写
							document.location.href = "workbench/index.jsp";
						} else {
							$("#msg").html(resp.msg);//msg待后端写
						}
					}
				})
			}
		})

	})
</script>




<body>
	<div style="position: absolute; top: 0px; left: 0px; width: 60%;">
		<img src="image/IMG_7114.JPG" style="width: 100%; height: 90%; position: relative; top: 50px;">
	</div>
	<div id="top" style="height: 50px; background-color: #3C3C3C; width: 100%;">
		<div style="position: absolute; top: 5px; left: 0px; font-size: 30px; font-weight: 400; color: white; font-family: 'times new roman'">CRM &nbsp;<span style="font-size: 12px;">&copy;2017&nbsp;动力节点</span></div>
	</div>
	
	<div style="position: absolute; top: 120px; right: 100px;width:450px;height:400px;border:1px solid #D5D5D5">
		<div style="position: absolute; top: 0px; right: 60px;">
			<div class="page-header">
				<h1>登录</h1>
			</div>
			<form action="workbench/index.jsp" class="form-horizontal" role="form">
				<div class="form-group form-group-lg">
					<div style="width: 350px;">
						<input class="form-control" type="text" placeholder="用户名" id="loginAct">
					</div>
					<div style="width: 350px; position: relative;top: 20px;">
						<input class="form-control" type="password" placeholder="密码" id="loginPwd">
					</div>
					<div class="checkbox"  style="position: relative;top: 30px; left: 10px;">
						
							<span id="msg" style="color: red"></span>
						
					</div>
					<button type="button" class="btn btn-primary btn-lg btn-block"  style="width: 350px; position: relative;top: 45px;" id="loginBtn">登录</button>
				</div>
			</form>
		</div>
	</div>
</body>
</html>