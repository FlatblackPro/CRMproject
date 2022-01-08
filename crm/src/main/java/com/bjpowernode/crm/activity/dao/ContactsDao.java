package com.bjpowernode.crm.activity.dao;

import com.bjpowernode.crm.activity.domain.TblContacts;

import java.util.List;

public interface ContactsDao {

    int saveContacts(TblContacts contacts);

    List<TblContacts> getContactPerson(String fullname);
}
