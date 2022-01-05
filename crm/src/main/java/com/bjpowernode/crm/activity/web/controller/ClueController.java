package com.bjpowernode.crm.activity.web.controller;

import com.bjpowernode.crm.activity.dao.ClueActivityRelationDao;
import com.bjpowernode.crm.activity.domain.TblActivity;
import com.bjpowernode.crm.activity.domain.TblClue;
import com.bjpowernode.crm.activity.domain.TblClueActivityRelation;
import com.bjpowernode.crm.activity.service.ActivityService;
import com.bjpowernode.crm.activity.service.ClueService;
import com.bjpowernode.crm.activity.service.Impl.ActivityServiceImpl;
import com.bjpowernode.crm.activity.service.Impl.ClueServiceImpl;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.Impl.UserServiceImpl;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.utils.DateTimeUtil;
import com.bjpowernode.crm.utils.PrintJson;
import com.bjpowernode.crm.utils.ServiceFactory;
import com.bjpowernode.crm.utils.UUIDUtil;
import com.bjpowernode.crm.vo.PaginationVO;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ClueController extends HttpServlet {

    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("进入到线索（潜在客户）控制器");
        String path = request.getServletPath();
        if ("/workbench/clue/getUser.do".equals(path)){
            getUser(request,response);

        }else if ("/workbench/clue/saveClue.do".equals(path)){
            saveClue(request,response);
        }
        else if ("/workbench/clue/getClue.do".equals(path)){
            getClue(request,response);
        }
        else if ("/workbench/clue/getDetail.do".equals(path)){
            getDetail(request,response);
        }
        else if ("/workbench/clue/showClueActivity.do".equals(path)){
            showClueActivity(request,response);
        }
        else if ("/workbench/clue/deleteClueActivityRelation.do".equals(path)){
            deleteClueActivityRelation(request,response);
        }
        else if ("/workbench/clue/getClueActivityRelation.do".equals(path)){
            getClueActivityRelation(request,response);
        }
        else if ("/workbench/clue/saveClueActivityRelation.do".equals(path)){
            saveClueActivityRelation(request,response);
        }
        else if ("/workbench/clue/convert.do".equals(path)){
            convert(request,response);
        }
        else if ("/workbench/clue/convertSearchAndShow.do".equals(path)){
            convertSearchAndShow(request,response);
        }
        else if ("/workbench/clue/clueConvert.do".equals(path)){
            clueConvert(request,response);
        }
        else if ("/workbench/clue/xxx.do".equals(path)){

        }
        else if ("/workbench/clue/xxx.do".equals(path)){

        }
        else if ("/workbench/clue/xxx.do".equals(path)){

        }
        else if ("/workbench/clue/xxx.do".equals(path)){

        }
        else if ("/workbench/clue/xxx.do".equals(path)){

        }


    }

    //核心功能：将线索转换为交易、或者客户联系人，然后删除这条线索。
    private void clueConvert(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入核心功能（交易转换）控制器");
        String clueId = request.getParameter("clueId");
        String flag = request.getParameter("flag");
        if ("true".equals(flag)){
            //需要创建交易
        }else {
            //不需要创建交易
        }
    }

    //点击转换按键，弹出转换的页面，通过活动名称搜索市场活动（仅搜索关联的市场活动）
    private void convertSearchAndShow(HttpServletRequest request, HttpServletResponse response) {
        String clueId = request.getParameter("clueId");
        String activityName = request.getParameter("activityName");
        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        List<TblActivity> activityList = activityService.convertSearchAndShow(clueId,activityName);
        PrintJson.printJsonObj(response,activityList);

    }

    //在线索详细信息页，点击转换按键，弹出转换的页面，并将相应的信息铺进去：
    private void convert(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String clueId = request.getParameter("clueId");
        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        TblClue clue = clueService.convert(clueId);
        request.setAttribute("clue",clue);
        request.getRequestDispatcher("/workbench/clue/convert.jsp").forward(request,response);
    }

    //在线索详细信息页，点击关联，打开模态窗口，关联市场活动
    private void saveClueActivityRelation(HttpServletRequest request, HttpServletResponse response) {
        boolean flag = true;
        String clueId = request.getParameter("clueId");
        String[] ids = request.getParameterValues("id");

        Map<String, Object> map = new HashMap<>();
        map.put("ids",ids);
        map.put("clueId",clueId);
        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        flag = clueService.saveClueActivityRelation(map);
        PrintJson.printJsonFlag(response,flag);
    }

    //在线索详细信息页，点击关联，打开模态窗口，搜索需要关联的市场活动：
    private void getClueActivityRelation(HttpServletRequest request, HttpServletResponse response) {
        String clueId = request.getParameter("clueId");
        String activityName = request.getParameter("activityName");
        Map<String,String> map = new HashMap<>();
        map.put("clueId",clueId);
        map.put("activityName",activityName);
        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        List<TblActivity> tblActivityList =  clueService.getClueActivityRelation(map);
        PrintJson.printJsonObj(response,tblActivityList);

    }

    //在线索详细信息页，用于解除市场活动和线索的关联：
    private void deleteClueActivityRelation(HttpServletRequest request, HttpServletResponse response) {
        Boolean flag = true;
        String relationId = request.getParameter("relationId");
        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        flag = clueService.deleteClueActivityRelation(relationId);
        PrintJson.printJsonFlag(response,flag);
    }

    //进入线索详细信息页后，展现关联该线索的市场活动：
    private void showClueActivity(HttpServletRequest request, HttpServletResponse response) {
        String clueId = request.getParameter("clueId");
        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        List<TblActivity> tblActivityList = activityService.showClueActivity(clueId);
        PrintJson.printJsonObj(response,tblActivityList);
    }

    //点击线索，进入详细信息页面：
    private void getDetail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String id = request.getParameter("id");
        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        TblClue tblClue = clueService.getDetail(id);
        request.setAttribute("clue", tblClue);
        request.getRequestDispatcher("/workbench/clue/detail.jsp").forward(request,response);
    }

    //刷新已更新、添加、修改的线索：
    private void getClue(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到线索查询控制器");
        Map<String, Object> map = new HashMap<>();
        String pageNoStr = request.getParameter("pageNo");
        String pageSizeStr = request.getParameter("pageSize");
        String fullname = request.getParameter("fullname");
        String owner = request.getParameter("owner");
        String company = request.getParameter("company");
        String phone = request.getParameter("phone");
        String mphone = request.getParameter("mphone");
        String state = request.getParameter("state");
        String source = request.getParameter("source");
        int pageNo = Integer.valueOf(pageNoStr);//1
        int pageSize = Integer.valueOf(pageSizeStr);//2
        /**
         * 这里需要计算页数：
         * pageNo：页数
         * pageSize：每页展示的条目数
         * SQL：select * from emp limit 0,5:略过0条记录，查5条--->1-5条（第一页）
         * SQL：select * from emp limit 5,5:略过5条记录，查5条--->6-10条（第二页）
         *
         */
        int pageCount = (pageNo-1)*pageSize;//从表中第几条数据开始查
        map.put("pageCount",pageCount);
        map.put("pageSize",pageSize);
        map.put("fullname",fullname);
        map.put("owner",owner);
        map.put("company",company);
        map.put("phone",phone);
        map.put("mphone",mphone);
        map.put("state",state);
        map.put("source",source);
        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        PaginationVO<TblClue> vo = clueService.getClue(map);
        PrintJson.printJsonObj(response,vo);

    }

    //添加线索功能：
    private void saveClue(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到线索添加控制器");
        Boolean flag;
        String id = UUIDUtil.getUUID();
        String fullname = request.getParameter("fullname");
        String appellation = request.getParameter("appellation");
        String owner = request.getParameter("owner");
        String company = request.getParameter("company");
        String job = request.getParameter("job");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String website = request.getParameter("website");
        String mphone = request.getParameter("mphone");
        String state = request.getParameter("state");
        String source = request.getParameter("source");
        String createBy = ((User)request.getSession().getAttribute("user")).getName();
        String createTime = DateTimeUtil.getSysTime();
        String description = request.getParameter("description");
        String contactSummary = request.getParameter("contactSummary");
        String nextContactTime = request.getParameter("nextContactTime");
        String address = request.getParameter("address");
        TblClue clue = new TblClue();
        clue.setId(id);
        clue.setFullname(fullname);
        clue.setAppellation(appellation);
        clue.setOwner(owner);
        clue.setCompany(company);
        clue.setJob(job);
        clue.setEmail(email);
        clue.setPhone(phone);
        clue.setWebsite(website);
        clue.setMphone(mphone);
        clue.setSource(source);
        clue.setState(state);
        clue.setCreateBy(createBy);
        clue.setCreateTime(createTime);
        clue.setDescription(description);
        clue.setContactSummary(contactSummary);
        clue.setNextContactTime(nextContactTime);
        clue.setAddress(address);
        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        flag = clueService.saveClue(clue);
        PrintJson.printJsonFlag(response,flag);
    }

    //获取用户的信息，然后填到创建线索模态窗口的用户下拉框中：
    private void getUser(HttpServletRequest request, HttpServletResponse response) {
        //直接调用USER的业务层进行处理（注意！！控制器必须使用clue的控制器，但是调取的业务层可以是USER的）：
        UserService userService = (UserService) ServiceFactory.getService(new UserServiceImpl());
        List<User> userList = userService.getUserList();
        PrintJson.printJsonObj(response,userList);
    }
}
