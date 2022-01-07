<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
%>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>


<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

<script type="text/javascript">
	$(function(){
		//初始化时间控件
		$(".time").datetimepicker({
			minView: "month",
			language:  'zh-CN',
			format: 'yyyy-mm-dd',
			autoclose: true,
			todayBtn: true,
			pickerPosition: "bottom-left"
		});
		//-------------------------------------
		$("#isCreateTransaction").click(function(){
			if(this.checked){
				$("#create-transaction2").show(200);
			}else{
				$("#create-transaction2").hide(200);
			}
		});

		/*
		2022/1/5新增：点击市场活动源放大镜，弹出模态窗口，搜索市场活动，选择。可以拿到数据
		 */
		$("#openSearchActivityModal").click(function () {
			$("#searchActivityModal").modal("show");
			$("#searchActivityResource").keydown(function (event) {
				if (event.keyCode == 13){
					$.ajax({
						url:"workbench/clue/convertSearchAndShow.do",
						dataType:"json",
						type:"post",
						data:{
							"clueId":"${clue.id}",
							"activityName":$.trim($("#searchActivityResource").val())
						},
						success:function (resp) {
							//data:{[市场活动1],[2],[3]}
							var html = "";
							$.each(resp,function (i,activity) {
								html += '<tr>';
								html += '<td><input type="radio" name="xz" value="'+activity.id+'"/></td>';
								html += '<td id="'+activity.id+'">'+activity.name+'</td>';
								html += '<td>'+activity.startDate+'</td>';
								html += '<td>'+activity.endDate+'</td>';
								html += '<td>'+activity.owner+'</td>';
								html += '</tr>';
							})
							$("#showActivitySource").html(html);
							$("#saveBtn").click(function () {
								/*
								通过选择器可以拿到value；
								val取值；html取内容；
								 */
								var activityId = $("input[name=xz]:checked").val();
								var activityName = $("#"+activityId).html();
								$("#activityId").val(activityId);
								$("#activity").val(activityName);
								$("#searchActivityModal").modal("hide");
							})

						}
					})
					return false;
				}
			})
		})
		/*
			<form id="convertForm">
			<input type="hidden" id="hidden-money">
			<input type="hidden" id="hidden-name">
			<input type="hidden" id="hidden-dealTime">
			<input type="hidden" id="hidden-stage">
			<input type="hidden" id="hidden-activitySource">
			</form>

			var money = $("#amountOfMoney").val();
			var tradeName = $("#tradeName").val();
			var expectedClosingDate = $("#expectedClosingDate").val();
			var stage = $("#stage").val();
			var source = $("#openSearchActivityModal").val();
		 */
		/*
		2022/1/5：新增：点击转换，将线索转换为交易
		 */
		$("#convertClueBtn").click(function () {
			if ($("#isCreateTransaction").prop("checked")){
				$("#clueConvert").submit();
			} else{
				window.location.href = "workbench/clue/clueConvert.do?clueId=${clue.id}";
			}
		})

	});
</script>

</head>
<body>

	<!-- 搜索市场活动的模态窗口 -->
	<div class="modal fade" id="searchActivityModal" role="dialog" >
		<div class="modal-dialog" role="document" style="width: 90%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">搜索市场活动</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input type="text" class="form-control" style="width: 300px;" placeholder="请输入市场活动名称，支持模糊查询" id="searchActivityResource">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>名称</td>
								<td>开始日期</td>
								<td>结束日期</td>
								<td>所有者</td>
								<td></td>
							</tr>
						</thead>
						<tbody id="showActivitySource">

						</tbody>
					</table>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-default" id="saveBtn">保存</button>
				</div>
			</div>
		</div>
	</div>

	<div id="title" class="page-header" style="position: relative; left: 20px;">
		<h4>转换线索 <small>${clue.fullname}${clue.appellation}-${clue.company}</small></h4>
	</div>
	<div id="create-customer" style="position: relative; left: 40px; height: 35px;">
		新建客户：${clue.company}
	</div>
	<div id="create-contact" style="position: relative; left: 40px; height: 35px;">
		新建联系人：${clue.fullname}${clue.appellation}
	</div>
	<div id="create-transaction1" style="position: relative; left: 40px; height: 35px; top: 25px;">
		<input type="checkbox" id="isCreateTransaction"/>
		为客户创建交易
	</div>
	<div id="create-transaction2" style="position: relative; left: 40px; top: 20px; width: 80%; background-color: #F7F7F7; display: none;" >
	
		<form id="clueConvert" action="workbench/clue/clueConvert.do" method="post">
			<%--
			挂载clueid，activityid等信息，通过表单提交的方式给到后台
			给表单加一个flag，用来标记是否为客户创建交易
			--%>
			<%--是否选择了创建交易--%>
			<input type="hidden" name="tranFlag" value="true">
			<%--关联市场活动的ID--%>
			<input type="hidden" id="activityId" name="activityId">
			<%--线索ID--%>
			<input type="hidden" id="clueId" name="clueId" value="${clue.id}">
			<%--交易相关的信息--%>
		  <div class="form-group" style="width: 400px; position: relative; left: 20px;">
		    <label for="amountOfMoney">金额</label>
		    <input type="text" class="form-control" id="amountOfMoney" name="money">
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="tradeName">交易名称</label>
		    <input type="text" class="form-control" id="tradeName" value="${clue.company}-" name="name">
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="expectedClosingDate">预计成交日期</label>
		    <input type="text" class="form-control time" id="expectedClosingDate" name="expectedDate">
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="stage">阶段</label>
		    <select id="stage"  class="form-control" name="stage">
		    	<c:forEach items="${applicationScope.stage}" var="stage">
					<option value="${stage.value}" >${stage.text}</option>
				</c:forEach>
		    </select>
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="activity">市场活动源&nbsp;&nbsp;<a href="javascript:void(0);" id="openSearchActivityModal" style="text-decoration: none;"><span class="glyphicon glyphicon-search"></span></a></label>
		    <input type="text" class="form-control" id="activity" placeholder="点击上面搜索" readonly>
		  </div>
		</form>
		
	</div>
	
	<div id="owner" style="position: relative; left: 40px; height: 35px; top: 50px;">
		记录的所有者：<br>
		<b>${clue.owner}</b>
	</div>
	<div id="operation" style="position: relative; left: 40px; height: 35px; top: 100px;">
		<input class="btn btn-primary" type="button" value="转换" id="convertClueBtn">
		&nbsp;&nbsp;&nbsp;&nbsp;
		<input class="btn btn-default" type="button" value="取消">
	</div>
</body>
</html>