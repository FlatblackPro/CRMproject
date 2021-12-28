package com.bjpowernode.crm.vo;

import java.util.List;

//要创建泛型的属性，必须要在类上加上泛型！
public class PaginationVO<T> {
    private int total;
    private List<T> dataList;

    @Override
    public String toString() {
        return "PaginationVO{" +
                "total=" + total +
                ", dataList=" + dataList +
                '}';
    }

    public int getTotal() {
        return total;
    }

    public void setTotal(int total) {
        this.total = total;
    }

    public List<T> getDataList() {
        return dataList;
    }

    public void setDataList(List<T> dataList) {
        this.dataList = dataList;
    }

    public PaginationVO() {
    }

    public PaginationVO(int total, List<T> dataList) {
        this.total = total;
        this.dataList = dataList;
    }
}
