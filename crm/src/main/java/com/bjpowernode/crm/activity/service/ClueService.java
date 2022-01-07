package com.bjpowernode.crm.activity.service;

import com.bjpowernode.crm.activity.domain.TblActivity;
import com.bjpowernode.crm.activity.domain.TblClue;
import com.bjpowernode.crm.activity.domain.TblTran;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.vo.PaginationVO;

import java.util.List;
import java.util.Map;

public interface ClueService {

    Boolean saveClue(TblClue clue);


    PaginationVO<TblClue> getClue(Map<String, Object> map);

    TblClue getDetail(String id);

    Boolean deleteClueActivityRelation(String relationId);

    List<TblActivity> getClueActivityRelation(Map<String, String> map);

    boolean saveClueActivityRelation(Map<String, Object> map);

    TblClue convert(String clueId);

    boolean clueConvert(String clueId, TblTran tran, String createBy);
}
