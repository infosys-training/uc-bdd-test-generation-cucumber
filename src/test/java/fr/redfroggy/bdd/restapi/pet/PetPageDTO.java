package fr.redfroggy.bdd.restapi.pet;

import java.util.List;

public class PetPageDTO {

    private List<PetDTO> content;

    private int page;

    private int size;

    private int totalElements;

    private int totalPages;

    public PetPageDTO(List<PetDTO> content, int page, int size, int totalElements, int totalPages) {
        this.content = content;
        this.page = page;
        this.size = size;
        this.totalElements = totalElements;
        this.totalPages = totalPages;
    }

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
}
