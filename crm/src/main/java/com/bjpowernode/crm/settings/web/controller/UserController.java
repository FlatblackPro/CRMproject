package com.bjpowernode.crm.settings.web.controller;

import com.bjpowernode.crm.exception.LoginException;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.Impl.UserServiceImpl;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.utils.PrintJson;
import com.bjpowernode.crm.utils.ServiceFactory;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class UserController extends HttpServlet {
    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("进入到用户控制器");
        //获取url-pattern：/settings/user/login.do（用哪个url-pattern登录，就获取哪个）
        String path = request.getServletPath();
        /*
        以下采用模板模式设计：
        控制器仅负责接收前端数据，然后交给service代理类进行处理。得到结果后，返回给前端。
         */
        if ("/settings/user/login.do".equals(path)){
            login(request,response);

        }else if ("/settings/user/xxx.do".equals(path)){

        }
    }
    private void login(HttpServletRequest request, HttpServletResponse response) {
        //先获取前端的用户输入(账号+密码+IP地址)：
        String loginAct = request.getParameter("loginAct");
        String loginPwd = request.getParameter("loginPwd");
        String userIp = request.getRemoteAddr();
        /*创建代理类
        userService就是被创建的代理对象。通过userService中，创建login方法，去处理具体业务.
        然后通过login方法，希望得到一个user对象，然后把user对象打给前端就好。
         */
        UserService userService = (UserService) ServiceFactory.getService(new UserServiceImpl());
        try {
            //业务层返回的对象
            User user = userService.login(loginAct, loginPwd, userIp);
            //将user对象放到session域中：
            request.getSession().setAttribute("user",user);
            //将前端需要的数据打回前端：
            //{"success":true}
            PrintJson.printJsonFlag(response,true);
        } catch (LoginException e) {
            //如果捕捉到异常，那么把异常要打回前端
            ////{"success":true, "msg":}
            //先取异常消息：
            String msg = e.getMessage();
            //由于这个异常信息不常用，因此通过MAP集合的方式，将值转为json传给前端
            Map<String, Object> map = new HashMap<>();
            map.put("success", false);
            map.put("msg",msg);
            //通过这个工具类，把对象传递给前端
            PrintJson.printJsonObj(response,map);
        }
    }
}
