package com.bjpowernode.crm.activity.service.Impl;

import com.bjpowernode.crm.activity.dao.ContactsDao;
import com.bjpowernode.crm.activity.dao.CustomerDao;
import com.bjpowernode.crm.activity.dao.TranDao;
import com.bjpowernode.crm.activity.dao.TranHistoryDao;
import com.bjpowernode.crm.activity.domain.TblCustomer;
import com.bjpowernode.crm.activity.domain.TblTran;
import com.bjpowernode.crm.activity.domain.TblTranHistory;
import com.bjpowernode.crm.activity.service.TranService;
import com.bjpowernode.crm.utils.DateTimeUtil;
import com.bjpowernode.crm.utils.SqlSessionUtil;
import com.bjpowernode.crm.utils.UUIDUtil;
import com.bjpowernode.crm.vo.PaginationVO;


import java.util.*;

public class TranServiceImpl implements TranService {
    private CustomerDao customerDao = SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);
    private TranDao tranDao = SqlSessionUtil.getSqlSession().getMapper(TranDao.class);
    private TranHistoryDao tranHistoryDao = SqlSessionUtil.getSqlSession().getMapper(TranHistoryDao.class);
    private ContactsDao contactsDao = SqlSessionUtil.getSqlSession().getMapper(ContactsDao.class);

    @Override
    /*
        添加交易历史
        添加交易本身
         */
    public boolean saveTransaction(TblTran tran, String customerName) {
        String customerId = customerDao.getCustomerIdByName(customerName);
        if (customerId == null){
            //如果没有这个客户，就创建一个：
            TblCustomer customer = new TblCustomer();
            customer.setId(UUIDUtil.getUUID());
            customer.setOwner(tran.getOwner());
            customer.setCreateTime(DateTimeUtil.getSysTime());
            customer.setCreateBy(tran.getCreateBy());
            customer.setNextContactTime(tran.getNextContactTime());
            customer.setDescription(tran.getDescription());
            customer.setContactSummary(tran.getContactSummary());
            customer.setName(customerName);

            int flag = customerDao.saveCustomer(customer);
            if (flag != 1){
                return false;
            }
        }
        tran.setCustomerId(customerId);
        //添加交易:
        int flag1 = tranDao.saveTran(tran);
        if (flag1 != 1){
            return false;
        }
        //添加交易历史：
        TblTranHistory tranHistory = new TblTranHistory();
        tranHistory.setId(UUIDUtil.getUUID());
        tranHistory.setTranId(tran.getId());
        tranHistory.setCreateBy(tran.getCreateBy());
        tranHistory.setCreateTime(tran.getCreateTime());
        tranHistory.setStage(tran.getStage());
        tranHistory.setMoney(tran.getMoney());
        tranHistory.setExpectedDate(tran.getExpectedDate());
        int flag2 = tranHistoryDao.saveTranHistory(tranHistory);
        if (flag2 != 1){
            return false;
        }
        return true;
    }

    @Override
    //交易搜索模块
    public PaginationVO<TblTran> getTran(Map<String, Object> map) {
        //获取customerId和contactId：
        List<String> customerList = customerDao.getCustomerIdListByName((String) map.get("customerName"));
        List<String> contactList = contactsDao.getContactIdNByName((String) map.get("contactName"));
        map.put("customerList",customerList);
        map.put("contactList",contactList);


        //查对应的交易：
        List<TblTran> tranList = tranDao.getTran(map);
        //通过查到的交易，反过来查customername/ContactName/owner(不写了)，然后放到customerId中显示：
        for (TblTran t:
             tranList) {
            String customerName = customerDao.getCustomerNameById(t.getCustomerId());
            t.setCustomerId(customerName);
            String contactName = contactsDao.getContactNameById(t.getContactsId());
            t.setContactsId(contactName);
        }
        //查total：
        Integer total = tranDao.getTranCount(map);
        PaginationVO<TblTran> vo = new PaginationVO<>();
        vo.setDataList(tranList);
        vo.setTotal(total);
        return vo;
    }

    @Override
    //点击交易，进入详细信息页面
    public TblTran detail(String tranId) {
        TblTran tran = tranDao.getTranById(tranId);
        return tran;
    }

    @Override
    //点击交易，进入详细信息页面，下方刷新展示该交易的历史信息
    public List<TblTranHistory> getHistory(String tranId) {
        /*
        1. 拿到交易对应的history阶段list；
        2. 拿到对应的possibility
         */
        Map<String, Object> map = new HashMap<>();
        List<TblTranHistory> historyList = tranHistoryDao.getHistoryByTranId(tranId);
        return historyList;
    }

    @Override
    //在详细信息页面，点击阶段图标，相应的阶段能够被更改
    public boolean changeStage(TblTran tran) {
        /*
        1. 更新tran中的数据
        2. 创建一条history
         */
        int flag1 = tranDao.updateTranById(tran);
        if (flag1 != 1){
            return false;
        }
        TblTranHistory history = new TblTranHistory();
        history.setId(UUIDUtil.getUUID());
        history.setMoney(tran.getMoney());
        history.setExpectedDate(tran.getExpectedDate());
        history.setStage(tran.getStage());
        history.setCreateTime(DateTimeUtil.getSysTime());
        history.setCreateBy(tran.getEditBy());
        history.setTranId(tran.getId());

        int flag2 = tranHistoryDao.saveTranHistory(history);
        if (flag2 != 1){
            return false;
        }

        return true;
    }

    @Override
    //显示图表
    public Map<String, Object> getChart() {
        Map<String, Object> map = new HashMap<>();
        List<String> legendList = new ArrayList<>();
        int total = tranDao.getTotal();
        // [{name:xx, value:xx},{},{}]
        List<Map<String, Object>> dataList = tranDao.getChartDatas();
        for (Map<String, Object> m:
             dataList) {
            legendList.add((String) m.get("name"));
        }
        map.put("total",total);
        map.put("dataList",dataList);
        map.put("legendList",legendList);
        for (String s:
             legendList) {
            System.out.println(s);
        }
        return map;
    }


}
