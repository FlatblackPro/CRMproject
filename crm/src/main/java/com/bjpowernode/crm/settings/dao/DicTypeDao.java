package com.bjpowernode.crm.settings.dao;

import com.bjpowernode.crm.settings.domain.TblDicType;

import java.util.List;

public interface DicTypeDao {

    List<TblDicType> getDicForListener();
}
