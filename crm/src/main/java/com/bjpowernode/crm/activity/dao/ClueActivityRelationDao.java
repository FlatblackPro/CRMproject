package com.bjpowernode.crm.activity.dao;


import com.bjpowernode.crm.activity.domain.TblActivity;
import com.bjpowernode.crm.activity.domain.TblClueActivityRelation;

import java.util.List;
import java.util.Map;

public interface ClueActivityRelationDao {


    int deleteClueActivityRelation(String relationId);


    int saveClueActivityRelation(TblClueActivityRelation relation);

    List<TblClueActivityRelation> getActivityIdByClueId(String clueId);

    int deleteClueActivityRelationByClueId(String clueId);
}
