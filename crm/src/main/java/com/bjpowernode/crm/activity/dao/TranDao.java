package com.bjpowernode.crm.activity.dao;

import com.bjpowernode.crm.activity.domain.TblTran;
import com.bjpowernode.crm.vo.PaginationVO;

import java.util.List;
import java.util.Map;

public interface TranDao {

    int saveTran(TblTran tran);

    List<TblTran> getTran(Map<String, Object> map);

    Integer getTranCount(Map<String, Object> map);

    TblTran getTranById(String tranId);

    int updateTranById(TblTran tran);
}
