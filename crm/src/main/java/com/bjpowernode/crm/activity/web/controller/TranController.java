package com.bjpowernode.crm.activity.web.controller;

import com.bjpowernode.crm.activity.dao.TranDao;
import com.bjpowernode.crm.activity.domain.*;
import com.bjpowernode.crm.activity.service.*;
import com.bjpowernode.crm.activity.service.Impl.*;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.Impl.UserServiceImpl;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.utils.DateTimeUtil;
import com.bjpowernode.crm.utils.PrintJson;
import com.bjpowernode.crm.utils.ServiceFactory;
import com.bjpowernode.crm.utils.UUIDUtil;
import com.bjpowernode.crm.vo.PaginationVO;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TranController extends HttpServlet {

    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("进入到交易控制器");
        String path = request.getServletPath();
        if ("/workbench/transaction/save.do".equals(path)){
            save(request,response);

        }else if ("/workbench/transaction/saveStage2Possibility.do".equals(path)){
            saveStage2Possibility(request,response);
        }
        else if ("/workbench/transaction/getContactPerson.do".equals(path)){
            getContactPerson(request,response);
        }
        else if ("/workbench/transaction/getActivityByContact.do".equals(path)){
            getActivityByContact(request,response);
        }
        else if ("/workbench/transaction/getCustomerName.do".equals(path)){
            getCustomerName(request,response);
        }
        else if ("/workbench/transaction/saveTransaction.do".equals(path)){
            saveTransaction(request,response);
        }
        else if ("/workbench/transaction/searchTransaction.do".equals(path)){
            searchTransaction(request,response);
        }
        else if ("/workbench/transaction/detail.do".equals(path)){
            detail(request,response);
        }
        else if ("/workbench/transaction/getHistory.do".equals(path)){
            getHistory(request,response);
        }
        else if ("/workbench/transaction/changeStage.do".equals(path)){
            changeStage(request,response);
        }

        else if ("/workbench/transaction/xxx.do".equals(path)){

        }
        else if ("/workbench/transaction/xxx.do".equals(path)){

        }
        else if ("/workbench/transaction/xxx.do".equals(path)){

        }
        else if ("/workbench/transaction/xxx.do".equals(path)){

        }

        ServletContext application = request.getServletContext();

    }
    //在详细信息页面，点击阶段图标，相应的阶段能够被更改
    private void changeStage(HttpServletRequest request, HttpServletResponse response) {
        String tranId = request.getParameter("tranId");
        String stage = request.getParameter("stage");
        String expectedDate = request.getParameter("expectedDate");
        String money = request.getParameter("money");
        TblTran tran = new TblTran();
        Map<String,Object> map = new HashMap<>();
        //处理可能性：
        ServletContext application = request.getServletContext();
        String possibility = (String) application.getAttribute(stage);
        //处理传值对象：
        tran.setStage(stage);
        tran.setEditBy(((User)request.getSession().getAttribute("user")).getName());
        tran.setEditTime(DateTimeUtil.getSysTime());
        tran.setMoney(money);
        tran.setExpectedDate(expectedDate);
        tran.setId(tranId);


        TranService tranService = (TranService) ServiceFactory.getService(new TranServiceImpl());
        //返回一个boolean和一个tran对象
        boolean flag = tranService.changeStage(tran);
        map.put("tran",tran);
        map.put("success",flag);
        map.put("possibility",possibility);
        PrintJson.printJsonObj(response,map);

    }

    //点击交易，进入详细信息页面，下方刷新展示该交易的历史信息
    private void getHistory(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入交易详细信息页，历史记录显示模块控制器");
        Map<String, Object> map = new HashMap<>();
        Map<String,String> possibilityMap = new HashMap<>();
        String tranId = request.getParameter("tranId");
        TranService tranService = (TranService) ServiceFactory.getService(new TranServiceImpl());
        List<TblTranHistory> historyList = tranService.getHistory(tranId);

        ServletContext application = request.getServletContext();
        for (TblTranHistory t:
             historyList) {
            String stage = t.getStage();
            String possibility = (String) application.getAttribute(stage);
            possibilityMap.put(stage,possibility);
            //{"stage1":"10","stage2":"25"...}
        }
        map.put("historyList",historyList);
        map.put("possibility",possibilityMap);
        PrintJson.printJsonObj(response,map);
    }

    //点击交易，进入详细信息页面
    private void detail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("进入交易详细信息页模块控制器");
        String tranId = request.getParameter("id");
        TranService tranService = (TranService) ServiceFactory.getService(new TranServiceImpl());
        TblTran tran = tranService.detail(tranId);
        request.setAttribute("tran",tran);
        request.getRequestDispatcher("/workbench/transaction/detail.jsp").forward(request,response);


    }

    //交易查询模块
    private void searchTransaction(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入交易查询模块控制器");
        String pageNoStr = request.getParameter("pageNo");
        String pageSizeStr = request.getParameter("pageSize");
        String owner = request.getParameter("owner");
        String name = request.getParameter("name");
        String customerName = request.getParameter("customerName");//目前没有ID
        String contactName = request.getParameter("contactName");//目前没有ID
        String stage = request.getParameter("stage");
        String type = request.getParameter("type");
        String source = request.getParameter("source");
        int pageNo = Integer.parseInt(pageNoStr);
        int pageSize = Integer.parseInt(pageSizeStr);
        /**
         * 这里需要计算页数：
         * pageNo：页数
         * pageSize：每页展示的条目数
         * SQL：select * from emp limit 0,5:略过0条记录，查5条--->1-5条（第一页）
         * SQL：select * from emp limit 5,5:略过5条记录，查5条--->6-10条（第二页）
         *
         */
        //这里的pageCount，也就是limit中的第一个参数，略过几条。
        int pageCount = (pageNo-1)*pageSize;
        Map<String, Object> map = new HashMap<>();
        map.put("owner", owner);
        map.put("name", name);
        map.put("stage", stage);
        map.put("type", type);
        map.put("source", source);
        map.put("pageCount",pageCount);
        map.put("pageSize",pageSize);
        map.put("customerName",customerName);
        map.put("contactName",contactName);
        TranService tranService = (TranService) ServiceFactory.getService(new TranServiceImpl());
        PaginationVO<TblTran> vo = tranService.getTran(map);
        PrintJson.printJsonObj(response,vo);

    }

    //添加交易模块
    private void saveTransaction(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        /*
        添加交易历史
        添加交易本身
         */
        System.out.println("进入交易添加控制器");
        TblTran tran = new TblTran();
        String id = UUIDUtil.getUUID();
        String owner = request.getParameter("owner");
        String money = request.getParameter("money");
        String name = request.getParameter("name");
        String expectedDate = request.getParameter("expectedDate");
        String customerName = request.getParameter("customerName");
        String stage = request.getParameter("stage");
        String type = request.getParameter("type");
        String source = request.getParameter("source");
        String activityId = request.getParameter("activityId");
        String contactsId = request.getParameter("contactsId");
        String createBy = ((User)request.getSession().getAttribute("user")).getName();
        String createTime = DateTimeUtil.getSysTime();
        String description = request.getParameter("description");
        String contactSummary = request.getParameter("contactSummary");
        String nextContactTime = request.getParameter("nextContactTime");

        tran.setId(id);
        tran.setOwner(owner);
        tran.setMoney(money);
        tran.setName(name);
        tran.setExpectedDate(expectedDate);
        tran.setStage(stage);
        tran.setType(type);
        tran.setSource(source);
        tran.setActivityId(activityId);
        tran.setContactsId(contactsId);
        tran.setCreateBy(createBy);
        tran.setCreateTime(createTime);
        tran.setDescription(description);
        tran.setContactSummary(contactSummary);
        tran.setNextContactTime(nextContactTime);
        TranService tranService = (TranService) ServiceFactory.getService(new TranServiceImpl());
        boolean flag = tranService.saveTransaction(tran,customerName);
        if (flag){
            //成功添加
            response.sendRedirect(request.getContextPath()+"/workbench/transaction/index.jsp");
        }


    }

    //在添加交易页面中，查询customer的姓名（公司名字），自动补全
    private void getCustomerName(HttpServletRequest request, HttpServletResponse response) {
        String name = request.getParameter("name");
        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        List<String> nameList = customerService.getCustomerName(name);
        PrintJson.printJsonObj(response,nameList);
    }

    //在添加交易页面中，打开查找市场活动源的模态窗口，搜索相关的市场活动：
    private void getActivityByContact(HttpServletRequest request, HttpServletResponse response) {
        String activityName = request.getParameter("activityName");
        String contactId = request.getParameter("contactId");
        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        List<TblActivity> activityList = activityService.getActivityByContact(activityName,contactId);
        PrintJson.printJsonObj(response,activityList);
    }

    //在添加交易页面中，打开查找联系人的模态窗口，搜索联系人：
    private void getContactPerson(HttpServletRequest request, HttpServletResponse response) {
        String fullname = request.getParameter("fullname");
        ContactService contactService = (ContactService) ServiceFactory.getService(new ContactServiceImpl());
        List<TblContacts> contactsList = contactService.getContactPerson(fullname);
        PrintJson.printJsonObj(response,contactsList);
    }

    //在添加交易页面中，根据选中的stage，显示可能性
    private void saveStage2Possibility(HttpServletRequest request, HttpServletResponse response) {
        String stage = request.getParameter("stage");
        ServletContext application = request.getServletContext();
        String possibility = (String) application.getAttribute(stage);
        PrintJson.printJsonObj(response,possibility);
    }

    //在添加交易页面中，显示操作者的姓名
    private void save(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        UserService userService = (UserService) ServiceFactory.getService(new UserServiceImpl());
        List<User> userList = userService.getUserList();
        request.setAttribute("userList",userList);
        request.getRequestDispatcher("/workbench/transaction/save.jsp").forward(request,response);
    }

}
