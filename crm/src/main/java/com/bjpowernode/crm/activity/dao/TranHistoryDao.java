package com.bjpowernode.crm.activity.dao;

import com.bjpowernode.crm.activity.domain.TblTranHistory;

import java.util.List;

public interface TranHistoryDao {

    int saveTranHistory(TblTranHistory tranHistory);

    List<TblTranHistory> getHistoryByTranId(String tranId);
}
