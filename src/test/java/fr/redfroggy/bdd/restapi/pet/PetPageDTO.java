package fr.redfroggy.bdd.restapi.pet;

import java.util.List;

public final class PetPageDTO {

    private List<PetDTO> content;

    private int totalElements;

    private int totalPages;

    private int page;

    private int size;

    public PetPageDTO(List<PetDTO> content, int totalElements, int totalPages, int page, int size) {
        this.content = content;
        this.totalElements = totalElements;
        this.totalPages = totalPages;
        this.page = page;
        this.size = size;
    }

    public List<PetDTO> getContent() {
        return content;
    }

    public void setContent(List<PetDTO> content) {
        this.content = content;
    }

    public int getTotalElements() {
        return totalElements;
    }

    public void setTotalElements(int totalElements) {
        this.totalElements = totalElements;
    }

    public int getTotalPages() {
        return totalPages;
    }

    public void setTotalPages(int totalPages) {
        this.totalPages = totalPages;
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
}
