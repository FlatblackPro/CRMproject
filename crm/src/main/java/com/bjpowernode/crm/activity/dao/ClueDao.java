package com.bjpowernode.crm.activity.dao;


import com.bjpowernode.crm.activity.domain.TblClue;
import com.bjpowernode.crm.activity.domain.TblClueActivityRelation;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

public interface ClueDao {

    int saveClue(TblClue clue);

    List<TblClue> getClue(Map<String, Object> map);


    int getClueTotal(Map<String, Object> map);

    TblClue getDetail(String id);

    TblClue getClueById(String clueId);

    int deleteClueByClueId(String clueId);
}
