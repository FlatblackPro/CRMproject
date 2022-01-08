package com.bjpowernode.crm.activity.dao;

import com.bjpowernode.crm.activity.domain.TblCustomer;

import java.util.List;

public interface CustomerDao {

    TblCustomer getCustomerByCompany(String company);


    int saveCustomer(TblCustomer customer);

    List<String> getCustomerName(String name);
}
