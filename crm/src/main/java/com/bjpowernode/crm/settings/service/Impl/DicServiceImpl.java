package com.bjpowernode.crm.settings.service.Impl;

import com.bjpowernode.crm.settings.dao.DicTypeDao;
import com.bjpowernode.crm.settings.dao.DicValueDao;
import com.bjpowernode.crm.settings.domain.TblDicType;
import com.bjpowernode.crm.settings.domain.TblDicValue;
import com.bjpowernode.crm.settings.service.DicService;
import com.bjpowernode.crm.utils.ServiceFactory;
import com.bjpowernode.crm.utils.SqlSessionUtil;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class DicServiceImpl implements DicService {
    private DicTypeDao dicTypeDao = SqlSessionUtil.getSqlSession().getMapper(DicTypeDao.class);
    private DicValueDao dicValueDao = SqlSessionUtil.getSqlSession().getMapper(DicValueDao.class);
    @Override
    //将数据字典存放到监听器中：
    public Map<String, List<TblDicValue>> getDicForListener() {
        /*
        这里需要两个数据：
        1. map中的key——type的code；
        2. map中的value——value中的value；
         */
        //先通过调用DICTYPEDAO，查询出所有的CODE:
        Map<String, List<TblDicValue>> map = new HashMap<>();
        List<TblDicType> typeList = dicTypeDao.getDicForListener();
        for (TblDicType dictype:typeList) {
            //拿到每一个code：
            String code = dictype.getCode();
            //通过CODE，在DICvalue中查value：
            List<TblDicValue> valueList = dicValueDao.getDicValForListener(code);
            //将得到的一组对应CODE的VALUE，和CODE一起放入map：
            map.put(code,valueList);
        }
        return map;
    }
}
