package com.bjpowernode.crm.web.filter;

import com.bjpowernode.crm.settings.domain.User;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class LoginFilter implements Filter {
    @Override
    public void doFilter(ServletRequest req, ServletResponse resp, FilterChain filterChain) throws IOException, ServletException {
        System.out.println("进入恶意登录拦截器");
        /*
        增加过滤器，防止恶意登录行为。
        ***************************
        * 要通过过滤器，必须使用chain方法
        * 如果不通过过滤器，可以使用重定向和转发
        * 重定向：sendRedirection，但是不共享request域，由浏览器发出，一次重定向，浏览器发出2次请求
        * *****绝对路径都是从webapp开始往下顺！！*****
        * 重定向必须使用绝对路径（/项目名/资源名称）
        * 转发：senddispatcher，共享request域，由小猫内部转发，不管转发几次，浏览器过程中只发出一次请求
        * 转发使用的是相对路径（/资源名称）
        ***************************
        判断逻辑：
        1. 如果session域中有user对象，那么就放行；
        2. 如果没有user，那么不放行：使用重定向，打回登录页面
         */
        //这里的req和resp是servletRequest，这个类是HttpServletRequest的父类，所以要先强转拿到两个req和resp，然后从req中拿session
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) resp;

        //拿到了request和response，就可以拿到session了。
        User user = (User) request.getSession().getAttribute("user");

        //拿到session后就可以进行判断了：
        //首先，应该让访问login.jsp和.do文件：
        // *****request.getServletPath()是用来获取能够与“url-pattern”中匹配的路径，注意是完全匹配的部分，*的部分不包括。
        if ("/login.jsp".equals(request.getServletPath()) || "/settings/user/login.do".equals(request.getServletPath())){
            //request.getRequestDispatcher("/index.jsp").forward(request,response);
            //过滤器中，必须使用filterchain来通过过滤器！
            filterChain.doFilter(request,response);
        }else {
            if (null != user){
                //如果验证OK，那么就采用请求转发的形式（因为要用到session），访问主页面：
                //request.getRequestDispatcher("/index.jsp").forward(request,response);
                filterChain.doFilter(request,response);
            }
            //如果user为空：
            else {
                //此处使用重定向，重新定位到登录页：
                String path = request.getContextPath(); //contextpath就是用来拿项目名的：“/CRM”
                System.out.println(path+ "/login.jsp");
                response.sendRedirect( path+ "/login.jsp");
            }
        }
    }
}
