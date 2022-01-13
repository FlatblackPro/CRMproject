<%@ page import="java.util.Map" %>
<%@ page import="com.bjpowernode.crm.activity.domain.TblTran" %>
<%@ page import="java.util.List" %>
<%@ page import="com.bjpowernode.crm.settings.domain.TblDicValue" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
System.out.println(basePath);

/*
2022/1/12: 核心功能：交易阶段变更控制（点击图标，更换交易阶段）：
 */
	/**
	 * 从application域中，先拿到stage和possibility的对应关系：
	 * pmap的key：--->02需求分析
	 * pmap的value：--->25
	 * pmap的key：--->01资质审查
	 * pmap的value：--->10
	 * pmap的key：--->03价值建议
	 * pmap的value：--->40
	 */
	Map<String, String> relationMap = (Map<String, String>) application.getAttribute("relationMap");
	/**从application域中，拿到所有的stage：
	 * {"appellation":[教授对象,博士对象,先生对象,夫人对象,女士对象] ,"stage":[阶段对象。。。] ,
	 */
	List<TblDicValue> dicValueList = (List<TblDicValue>) application.getAttribute("stage");
	//从request域中，拿到tran对象(当前目标)：
	TblTran currentTran = (TblTran) request.getAttribute("tran");
	//确定XX的分界线：通过possibility来确定：
	//遍历所有的tbldicvalue对象
	int flag = 0;
	for (int i = 0; i < dicValueList.size(); i++) {
		String stage = dicValueList.get(i).getValue();
		String possibility = relationMap.get(stage);
		if ("0".equals(possibility)){
			flag = i;
			break;
		}
		//以上步骤确定了分界线。dicvalueList有序，因此遍历出来的顺序是1，2，3，4……


	}



%>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />

<style type="text/css">
.mystage{
	font-size: 20px;
	vertical-align: middle;
	cursor: pointer;
}
.closingDate{
	font-size : 15px;
	cursor: pointer;
	vertical-align: middle;
}
</style>
	
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>

<script type="text/javascript">

	//默认情况下取消和保存按钮是隐藏的
	var cancelAndSaveBtnDefault = true;
	
	$(function(){

		//2022/1/12：设置当前时间：
		var date = new Date();
		var year = date.getFullYear();
		var month = date.getMonth() + 1;
		var day = date.getDate();
		var time = year +'-'+ month +'-'+day;
		$("#currentTime").text(time);

		//处理交易历史列表：
		historyShow();
		//获取可能性：
		var stage = $("#divstage").text();
		$.ajax({
			url:"workbench/transaction/saveStage2Possibility.do",
			dataType:"json",
			type:"post",
			data:{
				"stage":"${tran.stage}",
			},
			success:function (resp) {
				$("#possibilityValue").html(resp);
			}
		})

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
			$(this).children("span").css("color","#E6E6E6");
		});
		
		
		//阶段提示框
		$(".mystage").popover({
            trigger:'manual',
            placement : 'bottom',
            html: 'true',
            animation: false
        }).on("mouseenter", function () {
                    var _this = this;
                    $(this).popover("show");
                    $(this).siblings(".popover").on("mouseleave", function () {
                        $(_this).popover('hide');
                    });
                }).on("mouseleave", function () {
                    var _this = this;
                    setTimeout(function () {
                        if (!$(".popover:hover").length) {
                            $(_this).popover("hide")
                        }
                    }, 100);
                });
		historyShow();
	});
	function historyShow() {
		var tranId = "${tran.id}"
		//交易历史处理：
		$.ajax({
			url:"workbench/transaction/getHistory.do",
			dataType:"json",
			type:"post",
			data:{
				"tranId":tranId
			},
			success:function (resp) {
				/*
				data:"historyList":[history对象1,history对象2,history对象3...],
					["对象1.stage":"possibility"...]
				}
				 */
				var html = "";
				$.each(resp.historyList,function (i,history) {
					html += '<tr>';
					html += '<td>'+history.stage+'</td>';
					html += '<td>'+history.money+'</td>';
					html += '<td>'+resp.possibility[history.stage]+'</td>';
					html += '<td>'+history.expectedDate+'</td>';
					html += '<td>'+history.createTime+'</td>';
					html += '<td>'+history.createBy+'</td>';
					html += '</tr>';
				})
				$("#history").html(html);
			}
		})
	}
	//2022/1/12：点击阶段图标，相应的阶段能够被更改
	//改变交易阶段
	//stage:需要改变的阶段
	//index：需要改变的阶段对应的下标
	function changeStage(stage,index) {
		$.ajax({
			url:"workbench/transaction/changeStage.do",
			dataType:"json",
			type:"post",
			data:{
				"stage":stage,
				"tranId":"${tran.id}",
				"expectedDate":"${tran.expectedDate}",
				"money":"${tran.money}"
			},
			success:function (resp) {
				/*
				data:{"flag":"t/f", stage:"....", possibility:"...",editBy,editTime...}
				 */
				if (resp.success){
					$("#bstage").html(resp.tran.stage);
					$("#possibilityValue").html(resp.possibility);
					$("#editTime").html('&nbsp;&nbsp;'+resp.tran.editTime);
					$("#editBy").html(resp.tran.editBy);
					//添加一条交易历史记录:
					var html = "";
					html += '<tr>';
					html += '<td>'+resp.tran.stage+'</td>';
					html += '<td>${tran.money}</td>';
					html += '<td>'+resp.possibility+'</td>';
					html += '<td>'+resp.tran.expectedDate+'</td>';
					html += '<td>'+resp.tran.editTime+'</td>';
					html += '<td>'+resp.tran.editBy+'</td>';
					html += '</tr>';
					$("#history").append(html);
					/*
					2022/1/13：阶段动态变化:
					 */
					changeTag(stage,index);
				} else {
					alert("阶段转换失败");
				}
			}
		})
	}
	/*
	2022/1/13：阶段动态变化:
	*/
	function changeTag(stage,index) {
		//当前阶段：
		var currentStage = stage;
		//当前阶段的可能性：
		var currentPossibility = $("#possibilityValue").html();
		//X和正常阶段的分界点：
		var flag = "<%=flag%>";

		//当前阶段是最后两个
		if (index >= flag){
			//开始遍历铺上图标：
			//确定前7个图标：
			for (var i = 0; i < flag; i++) {
				//--------黑圈
				$("#"+i).removeClass();
				$("#"+i).addClass("glyphicon glyphicon-record mystage");
				$("#"+i).css("color","#000000");
			}

			//开始遍历铺上图标：
			//确定后2个图标：
			for (var i = flag; i < <%=dicValueList.size()%>; i++) {
				//当前阶段=遍历出来的阶段，那么这个阶段就是红X
				if (index == i){
					//---------红X
					$("#"+i).removeClass();
					$("#"+i).addClass("glyphicon glyphicon-remove mystage");
					$("#"+i).css("color","#FF0000");




				} else{
					//---------黑X
					$("#"+i).removeClass();
					$("#"+i).addClass("glyphicon glyphicon-remove mystage");
					$("#"+i).css("color","#000000");



				}
			}
		//当前阶段不是最后两个
		} else {
			//开始铺前6个图标：
			for (var i = 0; i < flag; i++) {
				//如果比当前阶段小，那么就是绿色勾：
				if (i < index){
					//--------------绿勾
					$("#"+i).removeClass();
					$("#"+i).addClass("glyphicon glyphicon-ok-circle mystage");
					$("#"+i).css("color","#90F790");

				//当前阶段==遍历出来的阶段：
				} else if (i == index){
					//--------------绿色标记
					$("#"+i).removeClass();
					$("#"+i).addClass("glyphicon glyphicon-map-marker mystage");
					$("#"+i).css("color","#90F790");


				//遍历出来的阶段比当前阶段大--->还没有到达的阶段：
				} else {
					//-------------黑圈
					$("#"+i).removeClass();
					$("#"+i).addClass("glyphicon glyphicon-record mystage");
					$("#"+i).css("color","#000000");
				}
			}

			//开始铺后面两个图标：
			for (var i = flag; i < <%=dicValueList.size()%>; i++) {
				//--------------黑X
				$("#"+i).removeClass();
				$("#"+i).addClass("glyphicon glyphicon-remove mystage");
				$("#"+i).css("color","#000000");
			}
		}
	}
</script>

</head>
<body>
	
	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>${requestScope.tran.customerId}-${requestScope.tran.name} <small>￥${tran.money}</small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 250px;  top: -72px; left: 700px;">
			<button type="button" class="btn btn-default" onclick="window.location.href='edit.html';"><span class="glyphicon glyphicon-edit"></span> 编辑</button>
			<button type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
		</div>
	</div>

	<!-- 阶段状态 -->
	<div style="position: relative; left: 40px; top: -50px;">
		阶段&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<%
			//拿到tran对象(当前目标)的stage：
			String currentStage = currentTran.getStage();
			//拿到tran对象（当前目标）的possibility：
			String currentPossibility = relationMap.get(currentStage);
			//获取当前阶段的index：
			int index = 0;
			for (int i = 0; i < dicValueList.size(); i++) {
				String traversalStage = dicValueList.get(i).getValue();
				if (currentStage.equals(traversalStage)){
					index = i;
					break;
				}
			}
			/**此处进行业务逻辑判断
			 * 1. 如果当前stage的index大于flag：说明当前阶段在最后两个：
			 * 		-前7个stage——黑O
			 * 		-后两个stage有两种可能：黑X，红X
			 * 			1.1 如果当前stage等于遍历出来的stage——红X
			 * 			1.2 else——黑X
			 * 2. 如果当前stage的index小于flag，说明当前阶段在1-7以内：
			 * 		-后两个stage——黑X
			 * 		-前7个stage：
			 * 		2.1 如果小于当前阶段——绿✔
			 * 		2.2 如果等于当前阶段——绿点
			 * 		2.3 else——黑O
			 */
			/*********************************************************
			 * （先使用这种试试看）此处进行业务逻辑判断：通过可能性进行判断
			 * 1. 如果currentstage的possibility==0 ———> 当前阶段在最后两个
			 * 		1.1 前7个为黑O
			 * 		1.2 后两个需要判断：
			 * 			1.21：如果currentstage==遍历出来的stage 	———> 红X
			 * 			1.22：else———>黑X
			 *
			 *
			 *
			 *
			 */
			//如果currentstage的possibility = 0：
			if ("0".equals(currentPossibility)){
				/**
				 * 为什么需要遍历？
				 * 因为需要通过遍历去生成对应的图标！
				 */
				for (int i = 0; i < dicValueList.size(); i++) {
					String traversalStage = dicValueList.get(i).getValue();
					String traversalPossibility = relationMap.get(traversalStage);
					//此时不确定是黑X还是红X，但其余的都应该是黑O：
					if ("0".equals(traversalPossibility)){
						//如果currentstage=traversalstage，红X
						if (currentStage.equals(traversalStage)){
							//红X
		%>
		<span id="<%=i%>" onclick="changeStage('<%=traversalStage%>','<%=i%>')"
			  class="glyphicon glyphicon-remove mystage"
			  data-toggle="popover" data-placement="bottom"
			  data-content="<%=traversalStage%>" style="color: #FF0000;">
		</span>-----------
		<%
					}else {
						//黑X
		%>
		<span id="<%=i%>" onclick="changeStage('<%=traversalStage%>','<%=i%>')"
			  class="glyphicon glyphicon-remove mystage"
			  data-toggle="popover" data-placement="bottom"
			  data-content="<%=traversalStage%>" style="color: #000000;">
		</span>-----------
		<%
						}
					}else {
						//黑O
		%>
		<span id="<%=i%>" onclick="changeStage('<%=traversalStage%>','<%=i%>')"
			  class="glyphicon glyphicon-record mystage"
			  data-toggle="popover" data-placement="bottom"
			  data-content="<%=traversalStage%>" style="color: #000000;">
		</span>-----------
		<%
					}
				}
				//如果currentstage的possibility ！= 0：
			}else {
				for (int i = 0; i < dicValueList.size(); i++) {
					String traversalStage = dicValueList.get(i).getValue();
					String traversalPossibility = relationMap.get(traversalStage);
					//如果遍历出来的可能性=0：一定是黑X：
					if ("0".equals(traversalPossibility)){
						//黑X
		%>
		<span id="<%=i%>" onclick="changeStage('<%=traversalStage%>','<%=i%>')"
			  class="glyphicon glyphicon-remove mystage"
			  data-toggle="popover" data-placement="bottom"
			  data-content="<%=traversalStage%>" style="color: #000000;">
		</span>-----------
		<%
				//如果遍历出来的可能性！=0，需要分情况讨论，可能是黑O，可能是绿O，可能是绿勾
					}else {
						//如果遍历出来的i，小于当前阶段的下标index,说明这些是当前阶段之前的阶段：
						if (i < index){
							//绿勾
		%>
		<span id="<%=i%>" onclick="changeStage('<%=traversalStage%>','<%=i%>')"
			  class="glyphicon glyphicon-ok-circle mystage"
			  data-toggle="popover" data-placement="bottom"
			  data-content="<%=traversalStage%>" style="color: #90F790;">
		</span>-----------
		<%
						}else if (i == index){
							//绿标
		%>
		<span id="<%=i%>" onclick="changeStage('<%=traversalStage%>','<%=i%>')"
			  class="glyphicon glyphicon-map-marker mystage"
			  data-toggle="popover" data-placement="bottom"
			  data-content="<%=traversalStage%>" style="color: #90F790;">
		</span>-----------
		<%
						}else {
							//黑O
		%>
		<span id="<%=i%>" onclick="changeStage('<%=traversalStage%>','<%=i%>')"
			  class="glyphicon glyphicon-record mystage"
			  data-toggle="popover" data-placement="bottom"
			  data-content="<%=traversalStage%>" style="color: #000000;">
		</span>-----------
		<%
						}
					}

				}
			}
		%>
		<span class="closingDate" id="currentTime"></span>
	</div>
	
	<!-- 详细信息 -->
	<div style="position: relative; top: 0px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${requestScope.tran.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">金额</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${requestScope.tran.money}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${requestScope.tran.customerId}-${requestScope.tran.name}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">预计成交日期</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${requestScope.tran.expectedDate}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">客户名称</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${requestScope.tran.customerId}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">阶段</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;" id="divstage"><b id="bstage">${requestScope.tran.stage}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">类型</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${requestScope.tran.type}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">可能性</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;" >
				<b id="possibilityValue"></b>
			</div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">来源</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${requestScope.tran.source}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">市场活动源</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${requestScope.tran.activityId}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">联系人名称</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${requestScope.tran.contactsId}</b></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 60px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${requestScope.tran.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${requestScope.tran.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 70px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b id="editBy">${requestScope.tran.editBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;" id="editTime">${requestScope.tran.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 80px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${requestScope.tran.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 90px;">
			<div style="width: 300px; color: gray;">联系纪要</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${requestScope.tran.contactSummary}&nbsp;
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 100px;">
			<div style="width: 300px; color: gray;">下次联系时间</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${requestScope.tran.nextContactTime}&nbsp;</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
	</div>
	
	<!-- 备注 -->
	<div style="position: relative; top: 100px; left: 40px;">
		<div class="page-header">
			<h4>备注</h4>
		</div>
		
		<!-- 备注1 -->
		<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>哎呦！</h5>
				<font color="gray">交易</font> <font color="gray">-</font> <b>动力节点-交易01</b> <small style="color: gray;"> 2017-01-22 10:10:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>
		
		<!-- 备注2 -->
		<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>呵呵！</h5>
				<font color="gray">交易</font> <font color="gray">-</font> <b>动力节点-交易01</b> <small style="color: gray;"> 2017-01-22 10:20:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>
		
		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="添加备注..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button type="button" class="btn btn-primary">保存</button>
				</p>
			</form>
		</div>
	</div>
	
	<!-- 阶段历史 -->
	<div>
		<div style="position: relative; top: 100px; left: 40px;">
			<div class="page-header">
				<h4>阶段历史</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table id="activityTable" class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>阶段</td>
							<td>金额</td>
							<td>可能性</td>
							<td>预计成交日期</td>
							<td>创建时间</td>
							<td>创建人</td>
						</tr>
					</thead>
					<tbody id="history">

					</tbody>
				</table>
			</div>
			
		</div>
	</div>
	
	<div style="height: 200px;"></div>
	
</body>
</html>