package com.bjpowernode.crm.activity.web.controller;

import com.bjpowernode.crm.activity.domain.TblClue;
import com.bjpowernode.crm.activity.service.ClueService;
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
        else if ("/workbench/clue/xxx.do".equals(path)){

        }
        else if ("/workbench/clue/xxx.do".equals(path)){

        }

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
