package com.bjpowernode.crm.activity.service;

import com.bjpowernode.crm.activity.domain.TblContacts;

import java.util.List;

public interface ContactService {
    List<TblContacts> getContactPerson(String fullname);
}
