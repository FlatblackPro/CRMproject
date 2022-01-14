package com.bjpowernode.crm.activity.service;

import com.bjpowernode.crm.activity.domain.TblTran;
import com.bjpowernode.crm.activity.domain.TblTranHistory;
import com.bjpowernode.crm.vo.PaginationVO;

import java.util.List;
import java.util.Map;

public interface TranService {

    boolean saveTransaction(TblTran tran, String customerName);

    PaginationVO<TblTran> getTran(Map<String, Object> map);

    TblTran detail(String tranId);

    List<TblTranHistory> getHistory(String tranId);


    boolean changeStage(TblTran tran);

    Map<String, Object> getChart();
}
