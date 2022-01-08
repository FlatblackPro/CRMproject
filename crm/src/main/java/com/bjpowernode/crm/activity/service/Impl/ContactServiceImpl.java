package com.bjpowernode.crm.activity.service.Impl;

import com.bjpowernode.crm.activity.dao.ContactsDao;
import com.bjpowernode.crm.activity.domain.TblContacts;
import com.bjpowernode.crm.activity.service.ContactService;
import com.bjpowernode.crm.utils.SqlSessionUtil;

import java.util.List;

public class ContactServiceImpl implements ContactService {
    private ContactsDao contactsDao = SqlSessionUtil.getSqlSession().getMapper(ContactsDao.class);
    @Override
    //在添加交易页面中，打开查找联系人的模态窗口，搜索联系人：
    public List<TblContacts> getContactPerson(String fullname) {
        List<TblContacts> contactsList = contactsDao.getContactPerson(fullname);
        return contactsList;
    }
}
