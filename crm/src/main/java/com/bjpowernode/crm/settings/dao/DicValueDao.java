package com.bjpowernode.crm.settings.dao;

import com.bjpowernode.crm.settings.domain.TblDicValue;

import java.util.List;

public interface DicValueDao {
    List<TblDicValue> getDicValForListener(String code);
}
