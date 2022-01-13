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
	<%--分页组件--%>
	<link type="text/css" rel="stylesheet" href="jquery/bs_pagination/jquery.bs_pagination.min.css/">
	<script type="text/javascript" src="jquery/bs_pagination/en.js"></script>
	<script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
<script type="text/javascript">

	$(function(){
		/*
		2022/1/10:新增查询功能：
		 */
		getTran(1,2);
		$("#searchBtn").click(function () {
			getTran(1,2);
		})
	});
	function getTran(pageNo,pageSize) {
		var owner = $.trim($("#owner").val());
		var name = $.trim($("#name").val());
		var customerName = $.trim($("#customerName").val());
		var contactName = $.trim($("#contactName").val());
		var stage = $.trim($("#stage option:selected").val());
		var type = $.trim($("#type option:selected").val());
		var source = $.trim($("#create-clueSource option:selected").val());
		$.ajax({
			url:"workbench/transaction/searchTransaction.do",
			dataType:"json",
			type:"post",
			data:{
				"pageNo":pageNo,
				"pageSize":pageSize,
				"owner":owner,
				"name":name,
				"customerName":customerName,
				"contactName":contactName,
				"stage":stage,
				"type":type,
				"source":source
			},
			success:function (resp) {
				/*
				data:{total:xxx,list(VO类)}
				dataList:[{map1},{map2}]
					</tr>
				 */
				var html = "";
				$.each(resp.dataList,function (i,tran) {
					html += '<tr class="active">';
					html += '"<td><input type="checkbox" /></td>';
					html += '"<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href=\'workbench/transaction/detail.do?id='+tran.id+'\';">'+tran.customerId+'-'+tran.name+'</a></td>';
					html += '"<td>'+tran.customerId+'</td>';
					html += '"<td>'+tran.stage+'</td>';
					html += '"<td>'+tran.type+'</td>';
					html += '"<td>'+tran.owner+'</td>';
					html += '"<td>'+tran.source+'</td>';
					html += '"<td>'+tran.contactsId+'</td>';
				})
				$("#showTran").html(html);
				var totalPages = resp.total%pageSize==0?resp.total/pageSize:parseInt(resp.total/pageSize)+1;
				//引入分页插件：
				$("#tranPage").bs_pagination({
					currentPage: pageNo, // 页码
					rowsPerPage: pageSize, // 每页显示的记录条数
					maxRowsPerPage: 5, // 每页最多显示的记录条数
					totalPages: totalPages, // 总页数
					totalRows: resp.total, // 总记录条数

					visiblePageLinks: 5, // 显示几个卡片

					showGoToPage: true,
					showRowsPerPage: true,
					showRowsInfo: true,
					showRowsDefaultInfo: true,
					onChangePage : function(event, data){
						//当触发翻页后，将隐藏域中的数据，给到textbox：
						$("#hidden-owner").val(owner);
						$("#hidden-name").val(name);
						$("#hidden-customerName").val(customerName);
						$("#hidden-contactName").val(contactName);
						$("#hidden-stage").val(stage);
						$("#hidden-type").val(type);
						$("#hidden-source").val(source);
						//6. 翻页后触发；
						getTran(data.currentPage , data.rowsPerPage);
						//翻页后，全选标记应该变为无：
						/*$("#selectActivity").prop("checked",false);*/
					}
				});




			}
		})
	}
	
</script>
</head>
<body>
	<input type="hidden" id="hidden-owner">
	<input type="hidden" id="hidden-name">
	<input type="hidden" id="hidden-customerName">
	<input type="hidden" id="hidden-contactName">
	<input type="hidden" id="hidden-stage">
	<input type="hidden" id="hidden-type">
	<input type="hidden" id="hidden-source">
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>交易列表</h3>
			</div>
		</div>
	</div>
	
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
	
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="owner">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="name">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">客户名称</div>
				      <input class="form-control" type="text" id="customerName">
				    </div>
				  </div>
				  
				  <br>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">阶段</div>
					  <select class="form-control" id="stage">
					  	<option></option>
					  	<c:forEach items="${stage}" var="stage">
							<option value="${stage.value}">${stage.text}</option>
						</c:forEach>
					  </select>
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">类型</div>
					  <select class="form-control" id="type">
					  	<option></option>
					  	<option>已有业务</option>
					  	<option>新业务</option>
					  </select>
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">来源</div>
				      <select class="form-control" id="create-clueSource">
						  <option></option>
						  <c:forEach items="${source}" var="s">
							  <option value="${s.value}">${s.text}</option>
						  </c:forEach>
						</select>
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">联系人名称</div>
				      <input class="form-control" type="text" id="contactName">
				    </div>
				  </div>
				  
				  <button type="button" class="btn btn-default" id="searchBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 10px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" onclick="window.location.href='workbench/transaction/save.do';"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" onclick="window.location.href='edit.html';"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
				
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" /></td>
							<td>名称</td>
							<td>客户名称</td>
							<td>阶段</td>
							<td>类型</td>
							<td>所有者</td>
							<td>来源</td>
							<td>联系人名称</td>
						</tr>
					</thead>
					<tbody id="showTran">

					</tbody>
				</table>
			</div>
			
			<div style="height: 50px; position: relative;top: 20px;">
				<div id="tranPage"></div>


			</div>
			
		</div>
		
	</div>
</body>
</html>