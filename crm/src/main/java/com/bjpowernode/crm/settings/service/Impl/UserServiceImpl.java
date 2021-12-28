package com.bjpowernode.crm.settings.service.Impl;

import com.bjpowernode.crm.exception.LoginException;
import com.bjpowernode.crm.settings.dao.UserDao;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.utils.DateTimeUtil;
import com.bjpowernode.crm.utils.MD5Util;
import com.bjpowernode.crm.utils.SqlSessionUtil;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class UserServiceImpl implements UserService {
    private UserDao userDao = SqlSessionUtil.getSqlSession().getMapper(UserDao.class);

    @Override
    public User login(String loginAct, String loginPwd, String userIp) throws LoginException {
        /*
        这里就是处理具体的业务逻辑，分析登录的几种情况，然后进行处理。
        1. 先调用dao，根据控制器传过来的数据，查数据库；
        2. 通过数据库查到的信息，进行业务编写：
            2.1：如果没有查到：异常——用户名密码错误；
            2.2：如果查到了：
                2.2.1：判断用户账号有效期；
                2.2.2：判断账号是否被封；
                2.2.3：判断IP地址是否有效；
         */
        System.out.println("进入到业务层");
        loginPwd = MD5Util.getMD5(loginPwd);
        //先去查数据，因为需要传入多个参数，因此将数据封装到vo类或者map中，此处由于偶尔调用一次，因此推荐map；
        Map<String, Object> userMap = new HashMap<>();
        userMap.put("loginAct",loginAct);
        userMap.put("loginPwd",loginPwd);

        //创建userDao的代理类对象，通过Mybatis连接数据库，对表进行查询，返回一个user对象。
        UserDao userDao = SqlSessionUtil.getSqlSession().getMapper(UserDao.class);
        User user = userDao.login(userMap);
        //2.1：如果没有查到：异常——用户名密码错误；
        if (null == user){
            throw new LoginException("账号密码错误");
        }
        //如果程序执行到此处，说明没有异常抛出，然后再进行其他业务逻辑的判断：
        //2.2：如果查到了：
            //2.2.1：判断用户账号有效期；
        String sysTime = DateTimeUtil.getSysTime();
        String expireTime = user.getExpireTime();
        //compareTo方法，用来比较两个字符串的大小，通过ASCII码，一个一个字符去比较。
        //如果CompareTo括号中的字符串小，那么返回>0；
        //此句逻辑：如果系统时间大于过期时间的话，说明过期，抛出异常
        if (sysTime.compareTo(expireTime) > 0){
            throw new LoginException("账号已过期");
        }
        //2.2.2：判断账号是否被封；
        if ("0".equals(user.getLockState())){
            throw new LoginException("账号已被封禁");
        }
        //2.2.3：判断IP地址是否有效：
        if (!user.getAllowIps().contains(userIp)){
            throw new LoginException("IP地址无效");
        }

        return user;
    }

    @Override
    public List<User> getUserList() {
        List<User> userList = userDao.getUserList();
        return userList;
    }
}
