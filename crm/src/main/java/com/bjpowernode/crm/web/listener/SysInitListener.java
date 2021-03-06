package com.bjpowernode.crm.web.listener;

import com.bjpowernode.crm.settings.domain.TblDicValue;
import com.bjpowernode.crm.settings.service.DicService;
import com.bjpowernode.crm.settings.service.Impl.DicServiceImpl;
import com.bjpowernode.crm.utils.ServiceFactory;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import java.util.*;

/*
通过监听器，在servlet工作的生命周期中，将数据字典放到application域中。
这样的话，用户在选取的时候，就不需要再走一遍数据库了，直接在服务器的内存中就可以拿到数据。
监听器和过滤器不同，监听器需要监听哪个域对象，就实现哪个域对象的接口。
 */

public class SysInitListener implements ServletContextListener {
    private DicService dicService = (DicService) ServiceFactory.getService(new DicServiceImpl());
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("进入全局作用域监听器");
        System.out.println("将数据字典存入application");
        ServletContext application = sce.getServletContext();
        /*
        监听器用法类似于控制器，在监听器中创建代理类去处理业务:
        需要的数据类型：
        {"appellation":[教授,博士,先生,夫人,女士] ,"clueState": ,"returnPriority": ,"returnState": ,"source": ,"stage": ,"transactionType":}
         所以application中存放的数据：
            key就是dictype表中的code；
            value就是code对应的dicvalue表中的value；
         */
        Map<String, List<TblDicValue>> map = dicService.getDicForListener();

        //2022/1/12：为阶段切换功能所准备的map：
        Map<String, String> relationMap = new HashMap<>();
        //将map中的key，放到set中，然后遍历set，拿到set对应的value
        //最后以"code":"valueList"的形式，将数据字典放到全局作用域中：
        Set<String> codeSet = map.keySet();
        for (String code:
             codeSet) {
            application.setAttribute(code,map.get(code));
        }



        System.out.println("将stage和possibility的关系存入application");
        ResourceBundle bundle = ResourceBundle.getBundle("stage2possibility");
        Enumeration stages = bundle.getKeys();
        while (stages.hasMoreElements()){
            /*
            {'stage1':'p1','stage2':'p2'...}
             */
            String stage = (String) stages.nextElement();
            String possibility = bundle.getString(stage);
            application.setAttribute(stage,possibility);
            //2022/1/12：为阶段切换功能所准备的map：
            relationMap.put(stage,possibility);

        }
        //2022/1/12：为阶段切换功能所准备的map：
        application.setAttribute("relationMap",relationMap);
/*          测试代码：
            Set<String> set = relationMap.keySet();
            for (String key:
             set) {
            System.out.println("relationMap的key：--->"+key);
            System.out.println("relationMap的value：--->"+relationMap.get(key));
        }*/
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {

    }
}
