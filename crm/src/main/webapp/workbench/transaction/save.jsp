<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
System.out.println(basePath);
%>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
<script type="text/javascript" src="jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>
</head>
<script>
	/*
	2022/1/8:新增：交易页面的添加处理
	 */
	$(function () {
		//-------------------------
		$("#create-customerName").typeahead({
			source: function (query, process) {
				$.post(
						"workbench/transaction/getCustomerName.do",
						{ "name" : query },
						function (data) {
							//alert(data);
							process(data);
						},
						"json"
				);
			},
			delay: 500
		});

		//-------------------------
		//初始化时间控件1
		$(".time1").datetimepicker({
			minView: "month",
			language:  'zh-CN',
			format: 'yyyy-mm-dd',
			autoclose: true,
			todayBtn: true,
			pickerPosition: "bottom-left"
		});
		//-------------------------------------
		//-------------------------
		//初始化时间控件2
		$(".time2").datetimepicker({
			minView: "month",
			language:  'zh-CN',
			format: 'yyyy-mm-dd',
			autoclose: true,
			todayBtn: true,
			pickerPosition: "top-left"
		});
		//-------------------------------------

		$("#create-transactionStage").change(function () {
			var stage = $("#create-transactionStage").val();
			$.ajax({
				url:"workbench/transaction/saveStage2Possibility.do",
				dataType:"json",
				type:"post",
				data:{
					"stage":stage
				},
				success:function (resp) {
					//{"possibility"}
					$("#create-possibility").val(resp);
				}
			})
		})
		/*
		2022/1/8:新增：点击市场联系人放大镜，后台搜索关联的联系人，并展示
		 */
		$("#openSearchContact").click(function () {
			$("#findContacts").modal("show");
			$("#inputContact").keydown(function (event) {
				if (event.keyCode == 13){
					var fullname = $.trim($("#inputContact").val());
					//提交数据
					$.ajax({
						url:"workbench/transaction/getContactPerson.do",
						dataType:"json",
						type:"post",
						data:{
							"fullname":fullname
						},
						success:function (resp) {
							//[person1,person2...]
							var html = "";
							$.each(resp,function (i,contact) {
								html += '<tr>';
								html += '<td><input type="radio" name="xz" value="'+contact.id+'"/></td>';
								html += '<td id="'+contact.id+'">'+contact.fullname+'</td>';
								html += '<td>'+contact.email+'</td>';
								html += '<td>'+contact.mphone+'</td>';
								html += '</tr>';
							})
							$("#showContact").html(html);
							$("#saveContact").click(function () {
								var contactId = $("input[name=xz]:checked").val();
								var contactName = $("#"+contactId).html();
								$("#hidden-contactId").val(contactId);
								$("#create-contactsName").val(contactName);
								$("#findContacts").modal("hide");
							})
						}
					})
					return false;
				}
			})
		})

        /*
		2022/1/8:新增：点击市场活动源放大镜，后台搜索关联的市场活动，并展示
		 */
        $("#openSearchActivity").click(function () {
            $("#findMarketActivity").modal("show");
            $("#searchActivity").keydown(function (event) {
                if (event.keyCode == 13){
                    var activityName = $.trim($("#searchActivity").val());
                    var contactId = $("#hidden-contactId").val();
                    $.ajax({
                        url: "workbench/transaction/getActivityByContact.do",
                        dataType: "json",
                        type: "post",
                        data: {
                            "activityName": activityName,
							"contactId":contactId
                        },
                        success: function (resp) {
                            var html = "";
                            $.each(resp,function (i,activity) {
                                html += '<tr>';
                                html += '<td><input type="radio" name="xz1" value="'+activity.id+'"/></td>';
                                html += '<td id="'+activity.id+'">'+activity.name+'</td>';
                                html += '<td>'+activity.startDate+'</td>';
                                html += '<td>'+activity.endDate+'</td>';
                                html += '<td>'+activity.owner+'</td>';
                                html += '</tr>';
                            })
                            $("#showActivity").html(html);
                            $("#saveActivity").click(function () {
                                var activityId = $("input[name=xz1]:checked").val();
                                var activityName = $("#"+activityId).html();
                                $("#hidden-activityId").val(activityId);
                                $("#create-activitySrc").val(activityName);
                                $("#findMarketActivity").modal("hide");
                            })
                        }
                    })
                    return false;
                }
            })
        })
		/*2022/1/9:新增：交易添加功能

		 */
		$("#cancelSaveTran").click(function () {
			window.location.href = "workbench/transaction/index.jsp";
		})
		$("#saveTran").click(function () {
			$("#saveTranForm").submit();
		})

	})

</script>


<body>

	<!-- 查找市场活动 -->	
	<div class="modal fade" id="findMarketActivity" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">查找市场活动</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input id="searchActivity" type="text" class="form-control" style="width: 300px;" placeholder="请输入市场活动名称，支持模糊查询">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable3" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>名称</td>
								<td>开始日期</td>
								<td>结束日期</td>
								<td>所有者</td>
							</tr>
						</thead>
						<tbody id="showActivity">


						</tbody>
					</table>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<%--data-dismiss="modal":关闭模态窗口--%>
					<button type="button" class="btn btn-primary" id="saveActivity">保存</button>
				</div>
			</div>
		</div>
	</div>

	<!-- 查找联系人 -->	
	<div class="modal fade" id="findContacts" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">查找联系人</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">

						    <input type="text" class="form-control" style="width: 300px;" placeholder="请输入联系人名称，支持模糊查询" id="inputContact">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>名称</td>
								<td>邮箱</td>
								<td>手机</td>
							</tr>
						</thead>
						<tbody id="showContact">

						</tbody>
					</table>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<%--data-dismiss="modal":关闭模态窗口--%>
					<button type="button" class="btn btn-primary" id="saveContact">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	
	<div style="position:  relative; left: 30px;">
		<h3>创建交易</h3>
	  	<div style="position: relative; top: -40px; left: 70%;">
			<button type="button" class="btn btn-primary" id="saveTran">保存</button>
			<button type="button" class="btn btn-default" id="cancelSaveTran">取消</button>
		</div>
		<hr style="position: relative; top: -40px;">
	</div>
	<form class="form-horizontal" role="form" style="position: relative; top: -30px;" id="saveTranForm" action="workbench/transaction/saveTransaction.do" type="post">
		<div class="form-group">
			<label for="create-transactionOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="create-transactionOwner" name="owner">
				  <option>--请选择--</option>
				  <c:forEach items="${userList}" var="u">
					  <%--EL表达式三目运算符--%>
					  <option value="${u.id}"${user.id eq u.id ? "selected" : ""} >${u.name}</option>

				  </c:forEach>
				</select>
			</div>
			<label for="create-amountOfMoney" class="col-sm-2 control-label">金额</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-amountOfMoney" name="money">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-transactionName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-transactionName" name="name">
			</div>
			<label for="create-expectedClosingDate" class="col-sm-2 control-label">预计成交日期<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control time1" id="create-expectedClosingDate" readonly name="expectedDate">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-customerName" class="col-sm-2 control-label">客户名称<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-customerName" name="customerName" placeholder="支持自动补全，输入客户不存在则新建">
			</div>
			<label for="create-transactionStage" class="col-sm-2 control-label">阶段<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
			  <select class="form-control" id="create-transactionStage" name="stage">
			  	<option>--请选择--</option>
			  	<c:forEach items="${applicationScope.stage}" var="stage">
					<option value="${stage.value}" >${stage.text}</option>
				</c:forEach>
			  </select>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-transactionType" class="col-sm-2 control-label">类型</label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="create-transactionType" name="type">
				  <option></option>
				  <c:forEach items="${applicationScope.transactionType}" var="type">
					  <option value="${type.value}" >${type.text}</option>
				  </c:forEach>
				</select>
			</div>
			<label for="create-possibility" class="col-sm-2 control-label">可能性</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-possibility" readonly name="possibility">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-clueSource" class="col-sm-2 control-label">来源</label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="create-clueSource" name="source">
				  <option></option>
				  <c:forEach items="${source}" var="source">
                      <option value="${source.value}" >${source.text}</option>
                  </c:forEach>
				</select>
			</div>
			<label for="create-activitySrc" class="col-sm-2 control-label">市场活动源&nbsp;&nbsp;<a href="javascript:void(0);" id="openSearchActivity" ><span class="glyphicon glyphicon-search"></span></a></label>
			<div class="col-sm-10" style="width: 300px;">
                <input type="hidden" id="hidden-activityId" name="activityId">
				<input type="text" class="form-control" id="create-activitySrc" readonly>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-contactsName" class="col-sm-2 control-label">联系人名称&nbsp;&nbsp;<a href="javascript:void(0);" id="openSearchContact"><span class="glyphicon glyphicon-search"></span></a></label>
			<div class="col-sm-10" style="width: 300px;">
                <input type="hidden" id="hidden-contactId" name="contactId">
				<input type="text" class="form-control" id="create-contactsName" readonly>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-describe" class="col-sm-2 control-label">描述</label>
			<div class="col-sm-10" style="width: 70%;">
				<textarea class="form-control" rows="3" id="create-describe" name="description"></textarea>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
			<div class="col-sm-10" style="width: 70%;">
				<textarea class="form-control" rows="3" id="create-contactSummary" name="contactSummary"></textarea>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control time2" id="create-nextContactTime" name="nextContactTime" readonly>
			</div>
		</div>
		
	</form>
</body>
</html>