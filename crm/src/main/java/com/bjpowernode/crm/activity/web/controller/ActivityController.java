package com.bjpowernode.crm.activity.web.controller;

import com.bjpowernode.crm.activity.domain.TblActivity;
import com.bjpowernode.crm.activity.domain.TblActivityRemark;
import com.bjpowernode.crm.activity.service.ActivityService;
import com.bjpowernode.crm.activity.service.Impl.ActivityServiceImpl;
import com.bjpowernode.crm.exception.LoginException;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.Impl.UserServiceImpl;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.utils.*;
import com.bjpowernode.crm.vo.PaginationVO;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ActivityController extends HttpServlet {

    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("进入到市场活动控制器");

        //获取url-pattern：/settings/user/login.do（用哪个url-pattern登录，就获取哪个）
        String path = request.getServletPath();
        /*
        以下采用模板模式设计：
        控制器仅负责接收前端数据，然后交给service代理类进行处理。得到结果后，返回给前端。
         */
        if ("/workbench/activity/getUserList.do".equals(path)){
            List<User> userList = getUserList();
            //控制器，首先就是要创建代理类，帮控制器进行业务的处理：
            //因为要拿的是user的数据，所以应该创建user业务的代理类！！！
/*            UserService userService = (UserService) ServiceFactory.getService(new UserServiceImpl());
            //通过代理类的方法，返回一个List，再把list打回给前端
            List<User> userList = userService.getUserList();*/
            //通过printJson工具类，将userList打回给前端。
            //注意：因为已经设置了过滤器，所以这里不用额外进行格式转换
            PrintJson.printJsonObj(response,userList);


        }else if ("/workbench/activity/saveActivity.do".equals(path)){
            //执行添加市场活动操作：
            boolean flag = saveActivity(request,response);
            //将返回的flag封装到json对象中，然后打回前端：
            PrintJson.printJsonFlag(response,flag);
        }
        else if ("/workbench/activity/getActivity.do".equals(path)){

            getActivity(request, response);
        }
        else if ("/workbench/activity/deleteActivity.do".equals(path)){

            deleteActivity(request, response);
        }
        else if ("/workbench/activity/editActivity.do".equals(path)){

            editActivity(request, response);
        }
        else if ("/workbench/activity/editActivityUpdate.do".equals(path)){

            editActivityUpdate(request, response);
        }
        else if ("/workbench/activity/detail.do".equals(path)){

            detail(request, response);
        }
        else if ("/workbench/activity/detailRemark.do".equals(path)){

            detailRemark(request, response);
        }
        else if ("/workbench/activity/deleteRemark.do".equals(path)){

            deleteRemark(request, response);
        }
        else if ("/workbench/activity/saveRemark.do".equals(path)){

            saveRemark(request, response);
        }
        else if ("/workbench/activity/editRemark.do".equals(path)){

            editRemark(request, response);
        }




    }
    //备注信息修改功能：
    private void editRemark(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入修改备注信息控制器");
        String id = request.getParameter("remarkId");
        String noteContent = request.getParameter("noteContent");
        String editTime = DateTimeUtil.getSysTime();
        String editBy = request.getParameter("editBy");
        String editFlag = "1";
        TblActivityRemark tblActivityRemark = new TblActivityRemark();
        tblActivityRemark.setId(id);
        tblActivityRemark.setNoteContent(noteContent);
        tblActivityRemark.setEditFlag(editFlag);
        tblActivityRemark.setEditTime(editTime);
        tblActivityRemark.setEditBy(editBy);
        tblActivityRemark.setNoteContent(noteContent);
        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        boolean flag = activityService.editRemark(tblActivityRemark);
        PrintJson.printJsonFlag(response,flag);

    }

    //备注信息添加功能（评论）：
    private void saveRemark(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入备注信息添加控制器");
        String id = UUIDUtil.getUUID();
        String noteContent = request.getParameter("noteContent");
        String createTime = DateTimeUtil.getSysTime();
        String createBy = request.getParameter("createBy");
        String editFlag = "0";
        String activityId = request.getParameter("activityId");
        TblActivityRemark tblActivityRemark = new TblActivityRemark();
        tblActivityRemark.setActivityId(activityId);
        tblActivityRemark.setCreateBy(createBy);
        tblActivityRemark.setCreateTime(createTime);
        tblActivityRemark.setId(id);
        tblActivityRemark.setNoteContent(noteContent);
        tblActivityRemark.setEditFlag(editFlag);
        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        Boolean flag = activityService.saveRemark(tblActivityRemark);
        Map<String, Object> map = new HashMap<>();
        map.put("remark", tblActivityRemark);
        map.put("success",flag);
        PrintJson.printJsonObj(response,map);




    }

    //备注信息删除功能（评论）：
    private void deleteRemark(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入备注信息删除控制器");
        String remarkId = request.getParameter("remarkId");
        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        boolean flag = activityService.deleteRemark(remarkId);
        PrintJson.printJsonFlag(response,flag);
    }

    //在活动详细信息页展示备注信息（评论）：
    private void detailRemark(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到活动详细信息页展示备注信息控制器");
        String activityId = request.getParameter("activityId");
        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        //前端需要一个活动备注的数组：
        List<TblActivityRemark> tblActivityRemarks = activityService.detailRemark(activityId);
        System.out.println(tblActivityRemarks);
        PrintJson.printJsonObj(response,tblActivityRemarks);
    }

    //点击活动，进入活动详细信息页：
    private void detail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("进入到详细信息页面展示控制器");
        //通过传统请求的方式，来进行功能的实现：
        //首先从前端拿到活动的id：
        String ActivityId = request.getParameter("id");
        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        TblActivity tblActivity = activityService.detail(ActivityId);
        //将得到的对象，放到request域中：
        request.setAttribute("activity",tblActivity);
        request.getRequestDispatcher("/workbench/activity/detail.jsp").forward(request,response);
    }

    //模态窗口中编辑好数据，然后更新的操作：
    private void editActivityUpdate(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入市场活动更改模块2");
        Boolean flag = true;
        //从前端获取数据：
        String id = request.getParameter("id");
        //这里的owner是ownerId
        String owner = request.getParameter("owner");
        String name = request.getParameter("name");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String cost = request.getParameter("cost");
        String description = request.getParameter("description");
        String editBy = request.getParameter("editBy");
        String editTime = DateTimeUtil.getSysTime();
        //将数据打包成一个Map，传递给业务层：
        Map<String, Object> map = new HashMap<>();
        map.put("id",id);
        map.put("owner",owner);
        map.put("name",name);
        map.put("startDate",startDate);
        map.put("endDate",endDate);
        map.put("cost",cost);
        map.put("description",description);
        map.put("editBy",editBy);
        map.put("editTime",editTime);
        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        flag = activityService.editActivityUpdate(map);
        PrintJson.printJsonFlag(response,flag);
    }

    private void editActivity(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入市场活动更改模块1");
        //首先从前端拿数据：
        String id = request.getParameter("id");
        System.out.println(id);
        //根据ID，调用业务层，进行查询。返回一个map存放：1.ulist；2.活动信息
        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        Map<String, Object> map = activityService.editActivity(id);
        PrintJson.printJsonObj(response,map);
    }

    private void deleteActivity(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到市场活动删除控制器");
        boolean flag = false;
        //从前端ajax的data中，取出id，放到string数组中：
        String[] activityIds = request.getParameterValues("id");
        //创建业务类的代理类，帮忙处理业务：
        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        flag = activityService.deleteActivity(activityIds);
        //将结果返回：
        PrintJson.printJsonFlag(response,flag);

    }

    private void getActivity(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到活动搜索控制器");
        //获取业务层返回的信息：VO类
            /*
            业务总共有2个：
            1. 查询业务
            2. 获取total条目的业务
            所以调用业务层的不同方法，返回一个list和一个total，然后将两个数据装进new出来的VO类中，再将VO类封装为JSON打回去。
             */
        //通过前端取得数据：
        String name = request.getParameter("name");
        String owner = request.getParameter("owner");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String pageNoStr = request.getParameter("pageNo");
        String pageSizeStr = request.getParameter("pageSize");
        /**
         * 这里需要计算页数：
         * pageNo：页数
         * pageSize：每页展示的条目数
         * SQL：select * from emp limit 0,5:略过0条记录，查5条--->1-5条（第一页）
         * SQL：select * from emp limit 5,5:略过5条记录，查5条--->6-10条（第二页）
         *
         */
        //将前端拿到的数据，转换成数字：
        int pageNo = Integer.valueOf(pageNoStr);
        int pageSize = Integer.valueOf(pageSizeStr);
        //这里的pageCount，也就是limit中的第一个参数，略过几条。
        int pageCount = (pageNo-1)*pageSize;
        //这里的数据，不能打包成VO，因为VO是从后台打包数据，然后打回前端的！用于展现的！
        //所以这里只能使用Map打包数据，然后将数据传递到业务层！
        Map<String,Object> getActivityMap = new HashMap<>();
        getActivityMap.put("pageSize", pageSize);
        getActivityMap.put("pageCount", pageCount);
        getActivityMap.put("name", name);
        getActivityMap.put("owner", owner);
        getActivityMap.put("startDate", startDate);
        getActivityMap.put("endDate", endDate);

        //创建业务层的代理类，处理业务：
        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        /*调用业务层的方法，返回可以是map，也可以是vo类。
        目前需要业务层返回的是：
        1.市场活动的列表 List<TblActivity>
        2.分页的属性 int total
        由于之后有很多地方都会用到分页，因此这里建议使用vo类（市场行动使用泛型，因为以后不知道是传入什么）。
         */
        //返回市场活动列表+返回total，这两项全部放在业务层进行，返回一个VO对象给到控制器！！！：
        PaginationVO<TblActivity> VO = activityService.getActivity(getActivityMap);
        //封装VO类，并且打回前端：
        PrintJson.printJsonObj(response,VO);

    }

    private List<User> getUserList() {
        UserService userService = (UserService) ServiceFactory.getService(new UserServiceImpl());
        List<User> userList = userService.getUserList();
        return userList;
    }

    private boolean saveActivity(HttpServletRequest request, HttpServletResponse response) {

        //从前端接收ajax数据：
        String id = UUIDUtil.getUUID(); //这个市场活动的编号，通过UUID生成。
        String owner = request.getParameter("owner");
        String name = request.getParameter("name");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String cost = request.getParameter("cost");
        String description = request.getParameter("description");
        String createTime = DateTimeUtil.getSysTime();
        String createBy = ((User)request.getSession().getAttribute("user")).getName();

        //将前端数据封装到对象中：
        TblActivity tblActivity = new TblActivity();
        tblActivity.setId(id);
        tblActivity.setOwner(owner);
        tblActivity.setName(name);
        tblActivity.setStartDate(startDate);
        tblActivity.setEndDate(endDate);
        tblActivity.setCost(cost);
        tblActivity.setDescription(description);
        tblActivity.setCreateTime(createTime);
        tblActivity.setCreateBy(createBy);
        //这是市场活动的相关业务，因此使用市场活动的代理类来处理业务：
        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        //调用代理类的方法（代理类通过反射，从实现类中得到的方法）：
        boolean flag = activityService.saveActivity(tblActivity);
        return flag;
    }


}
