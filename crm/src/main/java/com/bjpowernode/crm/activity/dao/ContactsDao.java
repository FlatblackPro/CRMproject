package com.bjpowernode.crm.activity.dao;

import com.bjpowernode.crm.activity.domain.TblContacts;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

public interface ContactsDao {

    int saveContacts(TblContacts contacts);

    List<TblContacts> getContactPerson(String fullname);

    List<String> getContactIdNByName(@Param("contactName") String contactName);

    String getContactNameById(@Param("contactsId") String contactsId);
}
