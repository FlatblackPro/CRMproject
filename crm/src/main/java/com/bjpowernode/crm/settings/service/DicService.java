package com.bjpowernode.crm.settings.service;

import com.bjpowernode.crm.settings.domain.TblDicValue;

import java.util.List;
import java.util.Map;

public interface DicService {
    Map<String, List<TblDicValue>> getDicForListener();
}
