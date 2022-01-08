package com.bjpowernode.crm.activity.service.Impl;

import com.bjpowernode.crm.activity.dao.CustomerDao;
import com.bjpowernode.crm.activity.domain.TblCustomer;
import com.bjpowernode.crm.activity.service.CustomerService;
import com.bjpowernode.crm.utils.SqlSessionUtil;

import java.util.List;

public class CustomerServiceImpl implements CustomerService {
    private CustomerDao customerDao = SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);

    @Override
    public List<String> getCustomerName(String name) {
        List<String> nameList = customerDao.getCustomerName(name);
        return nameList;
    }
}
