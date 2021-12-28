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

<script type="text/javascript">

	//默认情况下取消和保存按钮是隐藏的
	var cancelAndSaveBtnDefault = true;
	
	$(function(){
		$("#remark").focus(function(){
			if(cancelAndSaveBtnDefault){
				//设置remarkDiv的高度为130px
				$("#remarkDiv").css("height","130px");
				//显示
				$("#cancelAndSaveBtn").show("2000");
				cancelAndSaveBtnDefault = false;
			}
		});
		
		$("#cancelBtn").click(function(){
			//显示
			$("#cancelAndSaveBtn").hide();
			//设置remarkDiv的高度为130px
			$("#remarkDiv").css("height","90px");
			cancelAndSaveBtnDefault = true;
		});
		
		$(".remarkDiv").mouseover(function(){
			$(this).children("div").children("div").show();
		});
		
		$(".remarkDiv").mouseout(function(){
			$(this).children("div").children("div").hide();
		});
		
		$(".myHref").mouseover(function(){
			$(this).children("span").css("color","red");
		});
		
		$(".myHref").mouseout(function(){
			$(this).children("span").css("color","#e6e6e6");
		});
		//1. 当用户点进某一条市场活动时（进入市场活动详细信息页）
		showRemark();
        saveRemark();

        //当点击更新时，进行ajax传数据：
        /*
        这个功能是编辑备注的一部分：
        因为触发了另一个事件，因此要重新写一个函数：
        写绑定事件的函数时，必须写在$(function)里面！！！
         */
        $("#updateRemarkBtn").click(function () {
            var id = $("#remarkId").val();
            var noteContent = $("#noteContent").val();
            $.ajax({
                url:"workbench/activity/editRemark.do",
                dataType:"json",
                type:"post",
                data:{
                    "remarkId":id,
                    "noteContent": noteContent,
                    "editBy":"${user.name}"
                },
                success:function (resp) {
                    if (resp.success){
                        alert("备注更新成功");
                        //4. 当用户修改了某一条评论后
                        showRemark();
                    } else {
                        alert("备注更新失败");
                    }
                }
            })
        })

	//2021/12/23：市场活动详细信息查询功能（点击市场活动，进入活动详细信息页）：
		/*
		使用传统的请求方式来做该功能：
		请求转发：共享同一个request域。（选用重定向来做）
		重定向：不同的request域。
		 */
//------------------------------动态显示添加/删除--------------------------------------
		$("#remarkArea").on("mouseover",".remarkDiv",function(){
			$(this).children("div").children("div").show();
		})
		$("#remarkArea").on("mouseout",".remarkDiv",function(){
			$(this).children("div").children("div").hide();
		})
//------------------------------动态显示添加/删除--------------------------------------





	});
	/*
		______________________________________________________________________________________
		刷新备注信息（评论）的业务场景：
		1. 当用户点进某一条市场活动时（进入市场活动详细信息页）————已组入
		2. 当用户新增评论后————已租入
		3. 当用户删除评论后————已组入
		4. 当用户修改了某一条评论后————已组入
		_______________________________________________________________________________________
		 */
	function showRemark() {
		//2021/12/24：市场活动详细信息查询功能——备注消息显示（评论功能）：
		//将活动的id，通过ajax传值给后端服务器：
		var activityId = "${activity.id}";
		$.ajax({
			url:"workbench/activity/detailRemark.do",
			dataType:"json",
			type:"get",
			data:{
				"activityId":activityId
			},
			success:function (resp) {
				/*需要的数据：
                TblActivityRemark对象列表（一个活动可能有多条评论）；
                通过ajax回传的数据，拼接html：
                xxx.html()方法，会将这个DOM内的其他内容全部清空，然后将方法体中的内容拼接进去！
                因此，比如某个DIV中有了内容，不能删除的话：
                1.可以找到“需要拼接html上方的那个标签”，然后用append方法，在这个标签的下方，追加！！html。
                2.可以找到“需要拼接html下方的那个标签”，然后用before方法，在这个标签的前面，追加！！！html。
                3.可以在内部新增一个div，然后起一个ID，用html方法拼接。
                <div class="remarkDiv" style="height: 60px;">
                <img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
                <div style="position: relative; top: -40px; left: 40px;" >
                <h5>哎呦！</h5>
                <font color="gray">市场活动</font> <font color="gray">-</font> <b>发传单</b> <small style="color: gray;"> 2017-01-22 10:10:10 由zhangsan</small>
                <div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
                &nbsp;&nbsp;&nbsp;&nbsp;
                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
                </div>
                </div>
                </div>
                */
				var html = "";
				$.each(resp, function (index,remark) {
					html += '<div id="'+remark.id+'" class="remarkDiv" style="height: 60px;">';
					html += '<img title="'+remark.createBy+'" src="image/user-thumbnail.png" style="width: 30px; height:30px;">';
					html += '<div style="position: relative; top: -40px; left: 40px;" >';
					html += '<h5 id="edit'+remark.id+'">'+remark.noteContent+'</h5>';
					html += '<font color="gray">市场活动</font> <font color="gray">-</font> <b>${activity.name}</b> <small style="color: gray;"> '+(remark.editFlag==1? remark.editTime: remark.createTime)+'由'+(remark.editFlag==1?remark.editBy:remark.createBy)+'</small>';
					html += '<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
					html += '<a class="myHref" href="javascript:void(0);" onclick="editRemark(\''+remark.id+'\')"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: orangered;"></span></a>';
					html += '&nbsp;&nbsp;&nbsp;&nbsp;';
					html += '<a class="myHref" href="javascript:void(0);" onclick="deleteRemark(\''+remark.id+'\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: orangered;"></span></a>';
					html += '</div>';
					html += '</div>';
					html += '</div>';
				})
				$("#remarkArea").html(html);
			}
		})
	}

	//2021/12/25：新增活动备注删除操作：
	/*
    由于DIV是动态生成的，而这个ID也是动态生成的，因此无法绑定。
    所以在<a>中，直接使用onclick的形式来触发函数。
     */
	/*
	注意：
	1. 如果在动态html中调用了一个带参的函数，那么在动态html中，参数必须，必须，必须以字符串的形式表示！
	2. 如果在动态html中调用某个函数，要把这个函数放到function外面！
	 */
	function deleteRemark(id){
        var confirm = window.confirm("是否确认删除？")
		if (confirm){
			//拿到id，然后通过ajax，将id给到服务器，根据ID删备注
			//返回的数据：flag，如果删除成功，那么调用showRemark（）做局部刷新。
			$.ajax({
				url:"workbench/activity/deleteRemark.do",
				dataType:"json",
				type:"post",
				data:{
					"remarkId":id
				},
				success:function (resp) {
					if (resp.success){
						alert("备注信息删除成功")
						//3. 当用户删除评论后：
						showRemark();
					} else {
						alert("备注信息删除失败")
					}
				}
			})
		}
	}

	//2021/12/25：新增活动备注新增操作：
	/*
    当用户点击保存：前端发送ajax请求至服务器端，进行添加操作：
    需要发送的数据：
        id———后端UUID生成
        ****noteContent————ajax
        createTime————后端生成
        ****createBy————前端EL表达式拿
        editTime————无
        editBy————无
        editFlag————0
        ****activityId————ajax
     */
	function saveRemark(){
		$("#saveRemark").click(function () {
			$.ajax({
				url:"workbench/activity/saveRemark.do",
				dataType:"json",
				type:"post",
				data:{
					"noteContent":$.trim($("#remark").val()),
					//由于活动放在request域中：
					"activityId":"${activity.id}",
					"createBy":"${user.name}"
				},
				success:function (resp) {
					if (resp.success){
						alert("添加备注成功");
						//重置textarea：
                        $("#remark").val("");
						//2. 当用户新增评论后
						showRemark();
					} else {
						alert("添加备注失败");
					}
				}
			})
		})
	}

	//2021/12/26:新增修改备注功能：
    /*
       弹框中只要更新备注内容即可。
       给服务器的数据：
       editTime:后台生成；
       editBy：后台生成；
       * editFlag：后台生成；
       * ***noteContent：ajax
       * ***editBy：ajax
       * ***id：ajax
       * 返回的数据：
       * flag
       * 成功后：
       * 1. 弹窗提示成功
       * 2. 局部刷新备注。
        */
    function editRemark(id) {
        //首先拿到文本框里的内容
        var noteContent = $.trim($("#edit"+id).html());
        //将文本框中的内容，给到模态窗口：
        $("#noteContent").val(noteContent);
        //需要将editRemark中的id进行赋值，给到模态窗口的隐藏域
        /*
        $("#editRemarkModal").modal("show");
        $("#updateRemarkBtn").click(function () {
        这是两个不同的事件，因此function中的id只对$("#editRemarkModal").modal("show")有效；
        所以另一个事件如果需要这个id，需要把ID先赋给需要这个id的DOM对象！！！
         */
        var id = $("#remarkId").val(id);
        $("#editRemarkModal").modal("show");
    }


</script>

</head>
<body>
	
	<!-- 修改市场活动备注的模态窗口 -->
	<div class="modal fade" id="editRemarkModal" role="dialog">
		<%-- 备注的id --%>
		<input type="hidden" id="remarkId">
        <div class="modal-dialog" role="document" style="width: 40%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title" id="myModalLabel">修改备注</h4>
                </div>
                <div class="modal-body">
                    <form class="form-horizontal" role="form">
                        <div class="form-group">
                            <label for="edit-describe" class="col-sm-2 control-label">内容</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="noteContent"></textarea>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                    <button type="button" class="btn btn-primary" id="updateRemarkBtn">更新</button>
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
                    <h4 class="modal-title" id="myModalLabel">修改市场活动</h4>
                </div>
                <div class="modal-body">

                    <form class="form-horizontal" role="form">

                        <div class="form-group">
                            <label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <select class="form-control" id="edit-marketActivityOwner">
                                    <option>zhangsan</option>
                                    <option>lisi</option>
                                    <option>wangwu</option>
                                </select>
                            </div>
                            <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-marketActivityName" value="发传单">
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="edit-startTime" class="col-sm-2 control-label">开始日期</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-startTime" value="2020-10-10">
                            </div>
                            <label for="edit-endTime" class="col-sm-2 control-label">结束日期</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-endTime" value="2020-10-20">
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="edit-cost" class="col-sm-2 control-label">成本</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-cost" value="5,000">
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="edit-describe" class="col-sm-2 control-label">描述</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="edit-describe">市场活动Marketing，是指品牌主办或参与的展览会议与公关市场活动，包括自行主办的各类研讨会、客户交流会、演示会、新产品发布会、体验会、答谢会、年会和出席参加并布展或演讲的展览会、研讨会、行业交流会、颁奖典礼等</textarea>
                            </div>
                        </div>

                    </form>

                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                    <button type="button" class="btn btn-primary" data-dismiss="modal">更新</button>
                </div>
            </div>
        </div>
    </div>

	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>市场活动-${activity.name} <small>${activity.startDate} ~ ${activity.endDate}</small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 250px;  top: -72px; left: 700px;">
			<button type="button" class="btn btn-default" data-toggle="modal" data-target="#editActivityModal"><span class="glyphicon glyphicon-edit"></span> 编辑</button>
			<button type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
		</div>
	</div>
	
	<!-- 详细信息 -->
	<div style="position: relative; top: -70px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${activity.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${activity.name}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>

		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">开始日期</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${activity.startDate}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">结束日期</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${activity.endDate}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">成本</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${activity.cost}&nbsp</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${activity.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${activity.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${activity.editBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${activity.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${activity.description}&nbsp;
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
	</div>
	
	<!-- 备注 -->
	<div style="position: relative; top: 30px; left: 40px;">
		<div class="page-header">
			<h4>备注</h4>
		</div>

		<div id="remarkArea">

		</div>
		<!-- 备注1 -->
		<%--<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>哎呦！</h5>
				<font color="gray">市场活动</font> <font color="gray">-</font> <b>发传单</b> <small style="color: gray;"> 2017-01-22 10:10:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>--%>
		
		<!-- 备注2 -->
<%--		<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>呵呵！</h5>
				<font color="gray">市场活动</font> <font color="gray">-</font> <b>发传单</b> <small style="color: gray;"> 2017-01-22 10:20:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>--%>
		
		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="添加备注..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button type="button" class="btn btn-primary" id="saveRemark">保存</button>
				</p>
			</form>
		</div>
	</div>
	<div style="height: 200px;"></div>
</body>
</html>