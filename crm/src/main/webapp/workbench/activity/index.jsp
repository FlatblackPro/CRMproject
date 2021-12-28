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



<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
	<%--分页组件--%>
	<link type="text/css" rel="stylesheet" href="jquery/bs_pagination/jquery.bs_pagination.min.css/">
	<script type="text/javascript" src="jquery/bs_pagination/en.js"></script>
	<script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
<%--日历组件--%>
	<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
	<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript">

	$(function(){
		//在js中，绑定按钮对象，然后进行操作。
		$("#addBtn").click(function () {
			//2021/12/15新增时间控件（日历）：
			//-------------------------
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
			//当点击click时，应该触发模态窗口，所以这里应该写触发模态窗口的代码：
			//通过jquery调用模态窗口，传入show即可实现：
			/*
			但是在弹出窗口之前，需求是弹出的窗口可以从数据库中拿到表中用户的姓名，以下拉框的形式返回，并且选择当前用户。
			因此需要在模态窗口弹出之前，先做ajax传值：
			 */
			$.ajax({
				url:"workbench/activity/getUserList.do",
				dataType:"json",
				//从session中拿到服务器返回的数据：function括号内的，就是返回的数据了。
				success:function (userList) {
					//服务器返回的userlist是Json形式的集合：
					//[{"id":"?","name":"?","age":?},{"id":"?","name":"?","age":?},{"id":"?","name":"?","age":?}...]
					//因此需要对集合中的每一个user进行遍历，拿到user里面的具体数据，比如名字。
					/*
					1. 首先定义好需要拼串的html
					2. 应该拿到标签，然后循环之后的内容，加入到标签中:create-marketActivityOwner。
					 */
					var html = "<option>--请选择--</option>";
					//each中的function的第一个参数是数组中的索引，第二个参数是数组中的每一个元素
					$.each(userList,function (index,user) {
						/*
						这里为什么不能使用EL表达式：
						因为返回的数据类型是一个数组，里面有张三、李四、王五，而EL表达式，是通过取作用域对象中的值，来传递数据的。
						所以这里如果用了EL表达式，那么由于数组中有2个元素，所以循环走2次，每一次都是从session中拿到了张三，所以：
						下拉列表中会有2个张三！
						 */
						/*html += "<option value='" + "<%--${sessionScope.user.id}--%>" + "'>" + "<%--${sessionScope.user.name}--%>" + "</option>"*/
						html += "<option value=" + user.id + ">" + user.name + "</option>"
					})
					//拿到标签，为标签赋值上面的html：
					$("#create-marketActivityOwner").html(html);
					//设置选中当前登录的人：
					//可以通过EL表达式，拿session作用域中的user.id属性，动态来进行选择
					//在Jquery中，设置很方便，通过val(xxx)函数就可以给标签赋指定的值：
					var id = "${sessionScope.user.id}";
					$("#create-marketActivityOwner").val(id);
				}
			})
			$("#createActivityModal").modal("show");
		})

		//2021-12-15新增添加功能：
		/*
		当用户填写时间时，必须使得endtime大于starttime
		当用户点击保存时，触发：
		首先要取得用户输入的数据，
		id 不需要，后端生成
		owner 不需要，直接后端从session中拿
		----------name 市场活动名
		----------startDate 开始时间
		----------endDate 结束时间
		----------cost 成本
		--description 活动描述
		createTime 创建时间，不需要，后端拿系统当前时间
		createBy 不需要，后端从session中拿
		editTime 暂时用不到
		editBy 暂时用不到
		1. 取得表单中各DOM的值（也就是用户的输入）
		2. 由于添加成功后，不希望页面重新刷新，因此使用AJAX将数据打到后端。
		3. 后端进行save操作
		4. 返回数据给前端（仅需要标志位即可）
		5. 如果添加成功：
			5.1：弹窗提醒用户，添加成功；
			5.2：关闭模态窗口；
			5.3: 再次打开模态窗口，历史信息已清除；
		*/
		$("#saveActivity").click(function () {
			var owner = "${sessionScope.user.id}";
			var name = $("#create-marketActivityName").val();
			var startDate = $("#create-startTime").val();
			var endDate = $("#create-endTime").val();
			var cost = $("#create-cost").val();
			var description = $("#create-description").val();
			if (startDate < endDate){
				//将添加函数进行封装，之后可以进行条件判断，比如带*的必须填写等等。
				insertActivity(owner, name,startDate,endDate,cost,description);

			}else {
				alert("结束日期必须大于开始日期！");
			}

		})

		//通过查询按钮，查询指定的市场行动条目：
		//1. 当点击查询时触发；
		/*
		注意事项：为了防止翻页后，搜索按键把text中的信息提交，所以此处使用了一个隐藏域：
		仅当用户点击了之后，才会提交text中数据，不然的话，比如翻页，数据就从隐藏域中拿。
		所以在点击button时，先把信息放到隐藏域中：
		*/
		$("#getActivityBtn").click(function () {
			//将用户输入的值，存入隐藏域中：
			$("#hidden-name").val($.trim($("#getName").val()));
			$("#hidden-owner").val($.trim($("#getOwner").val()));
			$("#hidden-startDate").val($.trim($("#getStartDate").val()));
			$("#hidden-endDate").val($.trim($("#getEndTime").val()));
			getActivity(1,2);
		})

		//市场行动添加功能
		function insertActivity(owner, name,startDate,endDate,cost,description) {
			$.ajax({
				url:"workbench/activity/saveActivity.do",
				type:"post",
				dataType:"json",
				data:{
					"owner":$.trim(owner),
					"name":$.trim(name),
					"startDate":$.trim(startDate),
					"endDate":$.trim(endDate),
					"cost":$.trim(cost),
					"description":$.trim(description)
				},
				success:function (resp) {
					//如果返回的flag是true，那么就代表添加成功了：
					//返回的data: {"success" : "true/false"};因为工具类中，返回的key就是success。
					if (resp.success){
						/*
                        市场活动添加成功后的需求：
                        1. 弹出提示：市场活动添加成功！
                        2. 关闭模态窗口
                        2.1:JQuery和DOM对象的相互转化：
                        J-D: $(jquery).[0];
                        D-J: $(dom);
                        */
						alert("添加成功！");
						$("#createActivityModal").modal("hide");
						$("#activityAdd")[0].reset();
						//2. 添加完市场活动后，触发异步刷新，将最新的活动列出来；
						getActivity(1,2);
					}
					//返回false，代表添加失败：
					else {
						alert("市场活动添加失败，请重试");
						$("#activityAdd")[0].reset();
					}
				}
			})
		}
		//页面加载后，就要进行异步刷新取得数据：
		//3. 点击导航栏市场活动后，触发；（也就是页面加载时触发！）
		getActivity(1,2);
		//市场行动查询功能
		function getActivity(pageNo,pageSize) {
			/*
____________________________________________________________________
			需要用到查询功能的场景：
			1. 当点击查询时触发；（已组入）
			2. 添加完市场活动后，触发；（已组入）
			3. 点击导航栏市场活动后，触发；（也就是页面加载时触发！）（已组入）
			4. 修改后触发；（已组入）
			5. 删除后触发；（已组入）
			6. 翻页后触发；（已组入）
____________________________________________________________________
			*/
			/*
			通过ajax异步请求的方式，向服务器端发送请求，包含参数：
			pageNo,pageSize,name,owner,startDate,endDate
			其中，后面4项参数可以没有，也可以有，因此后端要采用动态sql实现查询功能。
			 */

			$.ajax({
				url:"workbench/activity/getActivity.do",
				dataType:"json",
				type:"get",
				data:{
					"pageNo":pageNo,
					"pageSize":pageSize,
					"name":$.trim($("#getName").val()),
					"owner":$.trim($("#getOwner").val()),
					"startDate":$.trim($("#getStartDate").val()),
					"endDate":$.trim($("#getEndDate").val())
				},
				/*
				希望从后端返回的数据包括：
				1. 具体的活动list；[{"name":"??","owner":"??","startDate":"??","endDate":"??",}]
				2. 共有多少条记录（然后根据分页插件提供的pageNo和pageSize可以算出具体页数等信息）
				 */
				success:function (data) {
					//返回的活动列表：dataList
					//返回的记录数：total
					/*
					1. 拿到返回的活动列表后，通过html拼接的方式，将所有的信息进行展现；
					id = showGetActivity
					<tr class="active">
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">发传单123</a></td>
                            <td>zhangsan</td>
							<td>2020-10-10</td>
							<td>2020-10-20</td>
						</tr>
					2. 拿到返回的记录数，通过分页插件实现分页；
					 */
					var html = "";
					$.each(data.dataList, function (index, activity) {
						html += '<tr class="active">';
						html += '<td><input type="checkbox" name="singleBox" value="'+ activity.id +'"/></td>';
						html += '<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href=\'workbench/activity/detail.do?id='+activity.id+'\';">'+ activity.name +'</a></td>';
						html += '<td>'+ activity.owner +'</td>';
						html += '<td>'+ activity.startDate +'</td>';
						html += '<td>' + activity.endDate + '</td>';
						html += '</tr>';
					})
					$("#showGetActivity").html(html);

					//数据处理完毕后，再插入分页插件：
					/*
					1. 这里的bs_pagination是通过标签引入的插件中的JS文件。是已经写好的。
					2. 需要新增一个DIV，来体现这个插件，DIV的ID和activityPage一致。
					 */
					//先计算总页数：
					var totalPages = data.total%pageSize == 0?data.total/pageSize:parseInt(data.total/pageSize)+1;
					//引入分页插件：
					$("#activityPage").bs_pagination({
						currentPage: pageNo, // 页码
						rowsPerPage: pageSize, // 每页显示的记录条数
						maxRowsPerPage: 5, // 每页最多显示的记录条数
						totalPages: totalPages, // 总页数
						totalRows: data.total, // 总记录条数

						visiblePageLinks: 5, // 显示几个卡片

						showGoToPage: true,
						showRowsPerPage: true,
						showRowsInfo: true,
						showRowsDefaultInfo: true,
						onChangePage : function(event, data){
							//当触发翻页后，将隐藏域中的数据，给到textbox：
							$("#getName").val($.trim($("#hidden-name").val()));
							$("#getOwner").val($.trim($("#hidden-owner").val()));
							$("#getStartDate").val($.trim($("#hidden-startDate").val()));
							$("#getEndTime").val($.trim($("#hidden-endDate").val()));
							//6. 翻页后触发；
							getActivity(data.currentPage , data.rowsPerPage);
							//翻页后，全选标记应该变为无：
							$("#selectActivity").prop("checked",false);
						}
					});
				}
			})
		}
//__________________________________________________________________________________________________________________________________
		//市场活动选择框的全选和反选：
		//全选：
		$("#selectActivity").click(function () {
			/*
			1. 当勾选了这个复选框之后，其余本页所有的复选框都被选中；
			2. 当本页所有复选框都被选中之后，这个复选框也要被选中'
			*3.反选最重要的逻辑是：当复选框被选中的数量==复选框的总数量时，全选打勾。
			注意：
			表单选择器通过name选择：$("input[name=xxx]")
			表单选择器通过name，并且通过条件筛选：$("input[name=xxx]:selected/checked")
			 */
			/*
			prop操作的是当前节点对象的属性；
			prop(key,value)
				key	定义要设置值的属性名称。
				value	定义要设置的属性值。
			attr操作的是当前文档对象的属性；
			 */
			$("input[name=singleBox]").prop("checked",this.checked);
			$("#selectActivity").prop("checked",$("input[name=singleBox]").checked);
		})
		/*反选：由于复选框是动态生成的，因此需要找到其外层有效的元素：
		$.(外层的有效元素).on(绑定事件的方式，需要绑定的动态生成的jquery对象，回调函数)
		 */
		$("#showGetActivity").on("click",$("input[name=singleBox]"),function () {
			$("#selectActivity").prop("checked",$("input[name=singleBox]").length == $("input[name=singleBox]:checked").length);
		})
//__________________________________________________________________________________________________________________________________
		/*
		2021/12/20:添加删除数据功能：
		1. 点击删除按键，提示确实删除；
		2. 可以多条删除；
		3. 删除活动前，必须将活动关联的remark也删除；
		 */
		$("#deleteBtn").click(function () {

			/*
			$.each()用法：
			1. var xxx = $("...")，拿到所有的DOM对象，并且放到xxx数组中；（这是一个DOM数组！）
			2. $.each(要循环的数组，function（下标，数组内元素的标识符）{
				这里写代码，函数内的代码，DOM数组内的元素，每一个会执行一次。
			})
			 */
			//由于需要发送ajax请求，但是此次要发送到后台的数据不是json，所以要用字符串拼接：.do?id=xxx&id=xxx...
			var param = "";
			//首先需要拿到要删除的列表的值，由于有复选框，通过复选框可以拿到要删除的条目的ID值：
			var deleteBox = $("input[name=singleBox]:checked");

			$.each(deleteBox, function (index, element) {
				param += "id=" + element.value;
				//如果是最后一个元素，那么value后面就不需要+&:
				if (index != deleteBox.length-1){
					param += "&";
				}
			})
			//弹出确认框，询问用户是否确认删除x条记录
			/*alert(confirm("是否删除" + deleteBox.length + "条记录？"));*/
			/*
			*******************************
			* ***************************
			* ***************************
			* 注意：confirm的用法如下：
			 */
			var userConfirm = window.confirm("是否删除" + deleteBox.length + "条记录？")
			//当用户确认后，开始进行删除业务：
			if (userConfirm){
				//通过ajax请求，将data发送到服务器端：
				$.ajax({
					url:"workbench/activity/deleteActivity.do",
					dataType:"json",
					type:"post",
					data:param,
					success:function (resp) {
						if (resp.success){
							alert("已删除" + deleteBox.length + "条记录");
							//5. 删除后触发；
							getActivity(1,2);
						}else {
							alert("删除记录失败");
						}
					}
				})
			}
		})

		/*
		* 2021/12/21:添加修改数据功能：
		* 1. 点击修改按钮，通过ajax从后台拿到数据，进行展示，然后弹开模态窗口
		* 2. 在模态窗口中进行修改，并通过ajax到服务器，进行更新操作
		* */
		//事件功能：点击修改按钮，弹出模态窗口，后台信息可以显示。
		$("#editBtn").click(function () {
			//在点击编辑按钮时，引入日历
			$(".time").datetimepicker({
				minView: "month",
				language:  'zh-CN',
				format: 'yyyy-mm-dd',
				autoclose: true,
				todayBtn: true,
				pickerPosition: "bottom-left"
			});
			//不支持多选，因此必须是单选才可以:
			if ($("input[name=singleBox]:checked").length == 1){
				//首先通过选中的复选框，拿到活动的ID：
				var activityId = $("input[name=singleBox]:checked").val();
				//由于后续更新操作需要用到这个ID，所以先把这个ID放到一个隐藏域中：
				$("#edit-id").val(activityId);
				/*
                1. 根据ID，通过AJAX到服务器，查询这条ID对应的活动的具体信息
                2. AJAX需要的信息是：
                    2.1 用户列表：将用户列表做html拼接，放到owner这一栏中；
                    2.2 其他信息：将其他信息的值赋给对应的DOM对象；
                    所以data形式：{"uList":"[{user1},{user2}...]","activity":[{"id":".."},{"name":".."},...]}
                 */
				$.ajax({
					url:"workbench/activity/editActivity.do",
					dataType:"json",
					type:"get",
					data:{
						"id":activityId
					},
					success:function (resp) {
						/*当数据返回之后，需要从中取出两个对象：
                        1. uList---->用于拼接html，放到owner下拉框中
                        2. activity---->用于展示，并且可以修改
                         */
						//绑定下拉框按键,并从uList中取数据进行字符串拼接：
						var html = "";
						$.each(resp.uList, function (index,user) {
							html += '<option value="'+user.id+'">'+user.name+'</option>';
						})
						//将拼接好的字符串，赋值到对应的DOM中：
						$("#edit-marketActivityOwner").html(html);

						//绑定各个textbox，显示从服务器拿到的信息：
						/*
						获取owner：
						由于在动态html中拼接了value值（用的是id），所以如果要在下拉框取这个值，然后显示的话，就要用到这个value。
						设置了value后，用户看到的：value值对应的文本信息。
						*/
						$("#edit-marketActivityOwner").val(resp.activity.owner);
						$("#edit-marketActivityName").val(resp.activity.name);
						$("#edit-startTime").val(resp.activity.startDate);
						$("#edit-endTime").val(resp.activity.endDate);
						$("#edit-cost").val(resp.activity.cost);
						$("#edit-description").val(resp.activity.description);

						//弹出模态窗口，显示信息：
						$("#editActivityModal").modal("show");
					}
				})
			} else if ($("input[name=singleBox]:checked").length == 0) {
				alert("请选择需要修改的市场活动");
			}else {
				alert("市场活动修改操作仅可选择一条");
			}
		})

		//事件功能：弹出模态窗口，后台信息显示后，可以重新编辑信息，并且通过ID写入到后台服务器，写入后，进行pagelist刷新。
		$("#edit-updateBtn").click(function () {
			//从hidden域中拿到id
			var id = $("#edit-id").val();
			/*
			* 1. 拿到每一个DOM对象的值
			* 2. 通过ajax，将值传递给后端，进行update操作
			* 3. 返回标志位：true/false
			* 4. 基于标志位，给到用户处理结果提示
			* */
			//先取数据：（editTime到后端取）
			var ownerId = $("#edit-marketActivityOwner option:selected").val();
			var name = $("#edit-marketActivityName").val();
			var startDate = $("#edit-startTime").val();
			var endDate = $("#edit-endTime").val();
			var cost = $("#edit-cost").val();
			var description = $("#edit-description").val();
			var editBy = "${sessionScope.user.name}";
			if("" ==ownerId || null == ownerId){
				alert("活动所有者不能为空！");
			}else {
				$.ajax({
					url:"workbench/activity/editActivityUpdate.do",
					dataType:"json",
					type:"post",
					data:{
						"id":id,
						"owner":ownerId,
						"name":name,
						"startDate":startDate,
						"endDate":endDate,
						"cost":cost,
						"description":description,
						"editBy":editBy
					},
					success:function (resp) {
						if (resp){
							alert("市场活动更新完成")
							$("#editActivityModal").modal("hide");
							//这里需要调用ajax异步查询，刷新活动列表
							//4. 修改后触发；
							getActivity(1,2);
						} else{
							alert("市场活动更新失败")
						}
					}
				})
			}
/*
2021/12/22遗留BUG：
1.修改活动时，所有者应该是保持之前的人名；（已整改）
2.活动所有者变成null之后，数据库中的数据就拿不到了！！！（已整改）
 */

		})
	});
	
</script>
</head>
<body>

<input type="hidden" id="edit-id">

	<!-- 创建市场活动的模态窗口 -->
	<div class="modal fade" id="createActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form class="form-horizontal" role="form" id="activityAdd">
					
						<div class="form-group">
							<label for="create-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-marketActivityOwner">

								</select>
							</div>
                            <label for="create-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-marketActivityName">
                            </div>
						</div>
						
						<div class="form-group">
							<label for="create-startTime" class="col-sm-2 control-label time">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="create-startTime" readonly>
							</div>
							<label for="create-endTime" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="create-endTime" readonly>
							</div>
						</div>
                        <div class="form-group">

                            <label for="create-cost" class="col-sm-2 control-label">成本</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-cost">
                            </div>
                        </div>
						<div class="form-group">
							<label for="create-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-description"></textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<%--data-dismiss="modal":关闭模态窗口--%>
					<button type="button" class="btn btn-primary" id="saveActivity">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改市场活动的模态窗口 -->
	<div class="modal fade" id="editActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-marketActivityOwner">
<%--								  <option>zhangsan</option>
								  <option>lisi</option>
								  <option>wangwu</option>--%>
								</select>
							</div>
                            <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-marketActivityName">
                            </div>
						</div>

						<div class="form-group">
							<label for="edit-startTime" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="edit-startTime" readonly>
							</div>
							<label for="edit-endTime" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="edit-endTime" readonly>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-cost" class="col-sm-2 control-label">成本</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-cost">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<%--textarea赋值必须使用val()--%>
								<textarea class="form-control" rows="3" id="edit-description"></textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="edit-updateBtn">更新</button>
				</div>
			</div>
		</div>
	</div>
	
	
	
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>市场活动列表</h3>
			</div>
		</div>
	</div>
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="getName">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="getOwner">
				    </div>
				  </div>


				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">开始日期</div>
					  <input class="form-control" type="text" id="getStartTime" />
				    </div>
				  </div>
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">结束日期</div>
					  <input class="form-control" type="text" id="getEndTime">
				    </div>
				  </div>
				  
				  <button type="button" class="btn btn-default" id="getActivityBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
				<div class="btn-group" style="position: relative; top: 18%;">
					<%--这里把模态窗口给写死了，因此需要后端进行调整，降低耦合度，方便进行更多功能的扩展
<button type="button" class="btn btn-primary" data-toggle="modal" data-target="#createActivityModal"><span class="glyphicon glyphicon-plus"></span> 创建</button>
					比如要在点击创建后，先弹出一个对话框，那么靠这个标签是无法实现的。
					--%>
				  <button type="button" class="btn btn-primary" id="addBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default"  id="editBtn"><span class="glyphicon glyphicon-pencil" ></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="selectActivity"/></td>
							<td>名称</td>
                            <td>所有者</td>
							<td>开始日期</td>
							<td>结束日期</td>
						</tr>
					</thead>
					<tbody id="showGetActivity">
<%--						<tr class="active">
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">发传单123</a></td>
                            <td>zhangsan</td>
							<td>2020-10-10</td>
							<td>2020-10-20</td>
						</tr>
                        <tr class="active">
                            <td><input type="checkbox" /></td>
                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">发传单222</a></td>
                            <td>zhangsan</td>
                            <td>2020-10-10</td>
                            <td>2020-10-20</td>
                        </tr>--%>
					</tbody>
				</table>
			</div>
			
			<div style="height: 50px; position: relative;top: 30px;">
				<div id="activityPage"></div>
				<%--<div>
					<button type="button" class="btn btn-default" style="cursor: default;">共<b>50</b>条记录</button>
				</div>--%>
				<%--<div class="btn-group" style="position: relative;top: -34px; left: 110px;">
					<button type="button" class="btn btn-default" style="cursor: default;">显示</button>
					<div class="btn-group">
						<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
							10
							<span class="caret"></span>
						</button>
						<ul class="dropdown-menu" role="menu">
							<li><a href="#">20</a></li>
							<li><a href="#">30</a></li>
						</ul>
					</div>
					<button type="button" class="btn btn-default" style="cursor: default;">条/页</button>
				</div>--%>
				<%--<div style="position: relative;top: -88px; left: 285px;">
					<nav>
						<ul class="pagination">
							<li class="disabled"><a href="#">首页</a></li>
							<li class="disabled"><a href="#">上一页</a></li>
							<li class="active"><a href="#">1</a></li>
							<li><a href="#">2</a></li>
							<li><a href="#">3</a></li>
							<li><a href="#">4</a></li>
							<li><a href="#">5</a></li>
							<li><a href="#">下一页</a></li>
							<li class="disabled"><a href="#">末页</a></li>
						</ul>
					</nav>
				</div>--%>
			</div>
			
		</div>
		
	</div>
	<input type="hidden" id="hidden-name">
	<input type="hidden" id="hidden-owner">
	<input type="hidden" id="hidden-startDate">
	<input type="hidden" id="hidden-endDate">
</body>
</html>