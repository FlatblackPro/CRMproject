package com.bjpowernode.crm.activity.web.controller;

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
        else if ("/workbench/transaction/xxx.do".equals(path)){

        }
        else if ("/workbench/transaction/xxx.do".equals(path)){

        }
        else if ("/workbench/transaction/xxx.do".equals(path)){

        }
        else if ("/workbench/transaction/xxx.do".equals(path)){

        }

    }

    ////在添加交易页面中，查询customer的姓名（公司名字），自动补全
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
