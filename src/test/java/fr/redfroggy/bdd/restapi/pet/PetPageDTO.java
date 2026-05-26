package fr.redfroggy.bdd.restapi.pet;

import java.util.List;

public class PetPageDTO {

    private List<PetDTO> content;
    private int page;
    private int size;
    private long totalElements;
    private int totalPages;

    public List<PetDTO> getContent() {
        return content;
    }

    public void setContent(List<PetDTO> content) {
        this.content = content;
    }

    public int getPage() {
        return page;
    }

    public void setPage(int page) {
        this.page = page;
    }

    public int getSize() {
        return size;
    }

    public void setSize(int size) {
        this.size = size;
    }

    public long getTotalElements() {
        return totalElements;
    }

    public void setTotalElements(long totalElements) {
        this.totalElements = totalElements;
    }

    public int getTotalPages() {
        return totalPages;
    }

    public void setTotalPages(int totalPages) {
        this.totalPages = totalPages;
    }
}
