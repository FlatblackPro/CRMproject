package com.bjpowernode.crm.activity.dao;

import com.bjpowernode.crm.activity.domain.TblCustomer;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface CustomerDao {

    TblCustomer getCustomerByCompany(String company);

    int saveCustomer(TblCustomer customer);

    List<String> getCustomerName(String name);

    String getCustomerIdByName(String customerName);

    List<String> getCustomerIdListByName(@Param("customerName") String customerName);

    String getCustomerNameById(@Param("customerId") String customerId);
}
