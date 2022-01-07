package com.bjpowernode.crm.activity.dao;

import com.bjpowernode.crm.activity.domain.TblCustomer;

public interface CustomerDao {

    TblCustomer getCustomerByCompany(String company);


    int saveCustomer(TblCustomer customer);
}
