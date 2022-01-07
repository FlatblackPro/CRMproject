package com.bjpowernode.crm.activity.dao;

import com.bjpowernode.crm.activity.domain.TblClueRemark;

import java.util.List;

public interface ClueRemarkDao {

    List<TblClueRemark> getClueRemarkByClueId(String clueId);

    int deleteRemarkByClueId(String clueId);
}
